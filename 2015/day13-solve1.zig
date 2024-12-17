//! solution for https://adventofcode.com/2015/day/13 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var people: std.ArrayList([]const u8) = undefined;

var feelings = std.StringHashMap(i32).init(allocator);

var greatestHappiness: i32 = -9_999_999;


pub fn main() !void
{
    defer arena.deinit();

    const rawData: []const u8 = @embedFile("day13-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    people = try std.ArrayList([]const u8).initCapacity(allocator, 8);
    
    var lines = std.mem.splitAny(u8, data, "\n");
    
    while (lines.next()) | line | { try processInputLine(line); }
    
    for (people.items) | person | 
    { 
        var table = try std.ArrayList([]const u8).initCapacity(allocator, people.items.len);
        
        try table.append(person);

        try fillTable(&table); 
    }
    
    print("{d}\n", .{ greatestHappiness });
}

fn processInputLine(line: []const u8) !void
{
    var tokens = std.mem.splitAny(u8, line, " ");
    
    const person1 = tokens.next().?;
    
    _ = tokens.next(); // would
    
    const gainOrLose = tokens.next().?;
    
    const sign: i32 = if (std.mem.eql(u8, gainOrLose, "gain")) 1 else -1;
    
    const valueStr = tokens.next().?;
    
    const happiness = sign * try std.fmt.parseInt(i32, valueStr, 10);

    _ = tokens.next(); // happiness 
    _ = tokens.next(); // units
    _ = tokens.next(); // by 
    _ = tokens.next(); // sitting 
    _ = tokens.next(); // next
    _ = tokens.next(); // to

    const personDot = tokens.next().?;        
    const person2 = personDot[0..personDot.len-1];
    
    if (! personExists(person1)) { try people.append(person1); }
    if (! personExists(person2)) { try people.append(person2); } 
    
    const key = try makeKey(person1, person2);
    
    try feelings.put(key, happiness);
    
 //  print("{s}: {?}\n", .{ key, feelings.get(key) });
}

fn personExists(person: []const u8) bool
{
    for (people.items) |item|
    {
        if (std.mem.eql(u8, item, person)) { return true; }
    }
    return false;
}

fn fillTable(table: *std.ArrayList([]const u8)) !void
{
    defer table.deinit();
    
    if (table.items.len == people.items.len) { try evaluateTable(table); return; }
    
    for (people.items) | person |
    {
        if (tableHasPerson(table, person)) { continue; }
        
        var newTable = try table.clone();
        
        try newTable.append(person);
        
        try fillTable(&newTable);
    }    
}

fn tableHasPerson(table: *std.ArrayList([]const u8), person: []const u8) bool
{
    for (table.items) | item |
    {
        if (std.mem.eql(u8, person, item)) { return true; }            
    }
    return false;
}

fn evaluateTable(table: *std.ArrayList([]const u8)) !void
{    
    var happiness: i32 = 0;
    
    for (0..table.items.len) | index |
    {
        happiness += try calcHisHappiness(table, index);
    }
    
    if (happiness > greatestHappiness) { greatestHappiness = happiness; }
}

fn calcHisHappiness(table: *std.ArrayList([]const u8), index: usize) !i32
{
    const person = table.items[index];
    
    const maxIndex = table.items.len - 1;

    const previousIndex = if (index == 0) maxIndex else index - 1;
    
    const nextIndex = if (index == maxIndex) 0 else index + 1;
        
    const previousNeighbor = table.items[previousIndex];
    
    const nextNeighbor = table.items[nextIndex];
    
    const keyPrevious = try makeKey(person, previousNeighbor);
    
    const keyNext = try makeKey(person, nextNeighbor);
    
    const previousHappiness = feelings.get(keyPrevious);
    
    if (previousHappiness == null) { print("fodeu\n", .{});}
    
    const nextHappiness = feelings.get(keyNext);
    
    return previousHappiness.? + nextHappiness.?;
}

// helper /////////////////////////////////////////////////////////////////////

fn makeKey(person1: []const u8, person2: []const u8) ![]u8
{
    return try std.fmt.allocPrint(allocator, "{s}~{s}", .{ person1, person2 });
}

