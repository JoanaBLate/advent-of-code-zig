//! solution for https://adventofcode.com/2015/day/7 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();
  
     
const Kind = enum { assign, not, _and, _or, lshift, rshift }; // 'assign' means 'just a simple assignment'

const Rule = struct
{
    kind: Kind = undefined,
    operandA: []const u8 = "",
    operandB: []const u8 = "",
    destiny:  []const u8 = "",
    valueA:   ?u32 = null,
    valueB:   ?u32 = null
};

const Wire = struct
{
    name: []const u8,
    value: u32
};

var rules: std.ArrayList(Rule) = undefined;

var solvedWires: std.ArrayList(Wire) = undefined;

var result: u32 = undefined;


pub fn main() !void
{
    defer arena.deinit();       

    const rawData: []const u8 = @embedFile("day07-input.txt");

    const data = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");
    
    rules = try std.ArrayList(Rule).initCapacity(allocator, 350);
    
    solvedWires = try std.ArrayList(Wire).initCapacity(allocator, 50);
    
    while (lines.next()) |line| 
    {
        try processDataLine(line);
    }
        
    try extractStartingRules();
    try applySolvedWires();

    print("answer: {}\n", .{ result });
}

// transform input into rules /////////////////////////////////////////////////

fn processDataLine(line: []const u8) !void
{
    const rule = try createRule(line);
    
    try rules.append(rule);
}

fn createRule(line: []const u8) !Rule
{
    var rule = Rule{};
    
    var tokens = std.mem.tokenizeSequence(u8, line, " ");

    const firstToken = tokens.next().?;
    
    if (std.mem.eql(u8, firstToken, "NOT"))
    {
        rule.kind = .not;
        rule.operandA = tokens.next().?;
        rule.valueA = integerFromOperand(rule.operandA);
        _ = tokens.next(); // '->'
        rule.destiny = tokens.next().?;
        return rule;
    }
    
    rule.operandA = firstToken;
    rule.valueA = integerFromOperand(rule.operandA);
    
    const secondToken = tokens.next().?;
    
    if (std.mem.eql(u8, secondToken, "->"))
    {
        rule.destiny = tokens.next().?;
        rule.kind = .assign;
        return rule;
    }
        
    rule.operandB = tokens.next().?;
    rule.valueB = integerFromOperand(rule.operandB);
    
    _ = tokens.next(); // '->'
    rule.destiny = tokens.next().?;
         
    if (std.mem.eql(u8, secondToken, "AND"))      { rule.kind = ._and; }
    
    else if (std.mem.eql(u8, secondToken, "OR"))  { rule.kind = ._or;  }
    
    else if (std.mem.eql(u8, secondToken, "LSHIFT")) { rule.kind = .lshift; }
    
    else if (std.mem.eql(u8, secondToken, "RSHIFT")) { rule.kind = .rshift; }
    
    else { std.debug.panic("ERROR in processDataLine", .{}); }
        
    return rule;
}

fn integerFromOperand(operand: []const u8) ?u32
{
    if (operand[0] > '9') { return null; }
    
    const value = std.fmt.parseInt(u32, operand, 10) catch null;
    
    return value;
}

// value of the rule //////////////////////////////////////////////////////////

fn getRuleValue(rule: *Rule) ?u32
{
    if (rule.valueA == null) { return null; }
    const a = rule.valueA.?; 

    if (rule.kind == .assign) { return a; }
    
    if (rule.kind == .not) { return ~ a; }
    
    if (rule.valueB == null) { return null; }
    const b = rule.valueB.?; 
    
    if (rule.kind == ._and)   { return a & b; }
    if (rule.kind == ._or)    { return a | b; }
    
    // must be type u5 for lshift and rshift
    // can parse from string; canNOT cast from u32 
    const smallB: u5 = std.fmt.parseInt(u5, rule.operandB, 10) catch 
    {
        std.debug.panic("ERROR in getRuleValue", .{});
    };
    
    if (rule.kind == .lshift) { return a << smallB; }
    if (rule.kind == .rshift) { return a >> smallB; }
    
    std.debug.panic("ERROR in getRuleValue", .{});
}

// extracting starting rules //////////////////////////////////////////////////

fn extractStartingRules() !void 
{
    var index = rules.items.len; // counting done is safe for removing items
    while (index > 0)
    {
        index -= 1;
        const rule = &rules.items[index];        
        const value = getRuleValue(rule);
        if (value == null) { continue; }
    
        if (std.mem.eql(u8, "a", rule.destiny)) { result = value.?; }
        
        const wire = Wire{ .name = rule.destiny, .value = value.? };        
        try solvedWires.append(wire);
        
        _ = rules.swapRemove(index);
    }
}

// applying solved wires //////////////////////////////////////////////////////

fn applySolvedWires() !void
{
    while (solvedWires.items.len > 0)
    {
        try applySolvedWire(solvedWires.pop());
    }
}

fn applySolvedWire(wire: Wire) !void 
{
    var index = rules.items.len; // counting done is safe for removing items
    while (index > 0)
    {
        index -= 1;
        const rule = &rules.items[index];
        
        var changed = false;
        if (std.mem.eql(u8, wire.name, rule.operandA)) { rule.valueA = wire.value; changed = true; }
        if (std.mem.eql(u8, wire.name, rule.operandB)) { rule.valueB = wire.value; changed = true; } 
        if (! changed) { continue; }
        
        const value = getRuleValue(rule);
        if (value == null) { continue; }
    
        if (std.mem.eql(u8, "a", rule.destiny)) { result = value.?; }
        
        const newWire = Wire{ .name = rule.destiny, .value = value.? };        
        try solvedWires.append(newWire);
        
        _ = rules.swapRemove(index);
    }
}

// helper /////////////////////////////////////////////////////////////////////

fn printRule(rule: Rule) void
{
    print("\nkind: {any}\n", .{ rule.kind });
    print("operandA: {s}   valueA: {?}\n", .{ rule.operandA, rule.valueA });
    print("operandB: {s}   valueB: {?}\n", .{ rule.operandB, rule.valueB });
    print("destiny: {s}\n",  .{ rule.destiny });
}

