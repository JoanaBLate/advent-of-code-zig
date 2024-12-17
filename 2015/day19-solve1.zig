//! solution for https://adventofcode.com/2015/day/19 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var baseMedicine: []const u8 = undefined;
 
var newMedicines = std.StringHashMap(bool).init(allocator);


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day19-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var halves = std.mem.splitSequence(u8, data, "\n\n"); // mem.SplitIterator(u8,.sequence)
    
    const firstHalf: []const u8 = halves.next().?;
    
    var lines = std.mem.splitAny(u8, firstHalf, "\n");
    
    baseMedicine = halves.next().?;

    while (lines.next()) | line | { try parseReplacementLine(line); }
    
    print("answer: {}\n", .{ newMedicines.count() });    
}

fn parseReplacementLine(rawLine: []const u8) !void
{
    const line: []const u8 = std.mem.trimRight(u8, rawLine, " "); // probably this is not needed
    
    var tokens = std.mem.splitSequence(u8, line, " => ");
    
    const agent: []const u8 = tokens.next().?;
    const value: []const u8 = tokens.next().?;
    
    for (0..baseMedicine.len) | cursor |
    {
        const remaining = baseMedicine[cursor..];
        
        if (! std.mem.startsWith(u8, remaining, agent)) { continue; }
        
        const head = baseMedicine[0..cursor];
        
        const tailStart: usize = cursor + agent.len;
        
        const tail = baseMedicine[tailStart..];
        
        const newMedicine = try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ head, value, tail });
        
        try newMedicines.put(newMedicine, true); // a duplicated medicine replaces the original one
    }
}

