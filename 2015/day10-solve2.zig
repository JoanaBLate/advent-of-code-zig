//! solution for https://adventofcode.com/2015/day/10 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();


pub fn main() !void
{
    defer arena.deinit();

    const rawData: []const u8 = @embedFile("day10-input.txt");

    const data = std.mem.trimRight(u8, rawData, "\n\r ");

    var line = try std.ArrayList(u8).initCapacity(allocator, 10);
    
    try line.appendSlice(data);

    for (0..50) |_| { line = try processLine(line); }
    
    print ("answer: {}\n", .{ line.items.len });
}


fn processLine(oldLine: std.ArrayList(u8)) !std.ArrayList(u8)
{
    var count: u32 = 0; 
    var lastChar: u8 = undefined; 
    var newLine = try std.ArrayList(u8).initCapacity(allocator, oldLine.items.len * 2);
    
    for (oldLine.items) |c|
    {
        if (count == 0) { lastChar = c; count = 1; continue; }
        
        if (c == lastChar) { count += 1; continue; } 
        
        const countString = try std.fmt.allocPrint(allocator, "{d}", .{ count });         
        try newLine.appendSlice(countString);
        try newLine.append(lastChar);

        lastChar = c;
        count = 1;
    }

    const countString = try std.fmt.allocPrint(allocator, "{d}", .{ count }); 
    try newLine.appendSlice(countString);
    try newLine.append(lastChar);

    oldLine.deinit();

    return newLine;
}

