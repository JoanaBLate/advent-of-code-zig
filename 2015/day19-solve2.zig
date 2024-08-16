//! solution for https://adventofcode.com/2015/day/19 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Formula = struct
{
    agent: []const u8 = "",
    value: []const u8 = "",
};

var medicine: []const u8 = undefined; // will be reduced
 
var formulas: std.ArrayList(Formula) = undefined;


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day19-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    formulas = try std.ArrayList(Formula).initCapacity(allocator, 50);
    
    var halves = std.mem.splitSequence(u8, data, "\n\n"); // mem.SplitIterator(u8,.sequence)
    
    const firstHalf: []const u8 = halves.next().?;
  
    var lines = std.mem.splitAny(u8, firstHalf, "\n");
    
    medicine = halves.next().?;

    while (lines.next()) | line | { try parseReplacementLine(line); }
    
    var numberOfSteps: u32 = 0;
    
    while (medicine.len != 1) { try transformMedicineOnce(); numberOfSteps += 1; }
    
    print("answer: {}\n", .{ numberOfSteps });    
}

fn parseReplacementLine(rawLine: []const u8) !void
{
    const line: []const u8 = std.mem.trimRight(u8, rawLine, " "); // probably this is not needed
    
    var tokens = std.mem.splitSequence(u8, line, " => ");
    
    const agent: []const u8 = tokens.next().?;
    const value: []const u8 = tokens.next().?;
    
    const formula = Formula{ .agent = agent, .value = value };
    
    try formulas.append(formula);
}

fn transformMedicineOnce() !void // one of the formulas is granted to work (we are walking backwards)
{
    for (formulas.items) | formula |
    {       
        const success = try tryApplyFormula(formula);
        if (success) { return; }   
    }
}

fn tryApplyFormula(formula: Formula) !bool
{
    const agent = formula.agent;
    const value = formula.value;
    
    const index_ = std.mem.indexOf(u8, medicine, value);
        
    if (index_ == null) { return false; }
    
    const index = index_.?;
        
    const head = medicine[0..index];
    
    const tailStart: usize = index + value.len;
    
    const tail = medicine[tailStart..];
    
    medicine = try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ head, agent, tail });
    
    return true;
}

