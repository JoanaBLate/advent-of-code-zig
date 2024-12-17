//! solution for https://adventofcode.com/2020/day/02 part 2

const std = @import("std");

const print = std.debug.print;

// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
// const allocator = arena.allocator();

var countOfGood: u32 = 0;


pub fn main() !void
{
 // defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day02-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");
    
    while (lines.next()) | rawLine | 
    { 
        const line = std.mem.trimRight(u8, rawLine, " ");
    
        try processLine(line);
    }
    
    print("answer: {}\n", .{ countOfGood });
}

fn processLine(line: []const u8) !void
{
    var tokens = std.mem.splitAny(u8, line, " ");
    
    var range = std.mem.splitAny(u8, tokens.next().?, "-");
    
    const indexA = try std.fmt.parseInt(u32, range.next().?, 10);
    const indexB = try std.fmt.parseInt(u32, range.next().?, 10);
    
    const target = tokens.next().?[0];
    
    const heap = tokens.next().?;
    
    const foundAtA = heap[indexA - 1] == target;
    const foundAtB = heap[indexB - 1] == target;
    
    if (foundAtA  and  foundAtB) { return; }
    
    if (foundAtA  or  foundAtB) { countOfGood += 1; }
}

