//! solution for https://adventofcode.com/2020/day/09 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var numbers: std.ArrayList(usize) = undefined;


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day09-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var rawLines = std.mem.splitSequence(u8, data, "\n"); 
    
    numbers = try std.ArrayList(usize).initCapacity(allocator, 1000);
    
    while (rawLines.next()) | rawLine | 
    { 
        const line = std.mem.trimRight(u8, rawLine, " ");
       
        const number: usize = try std.fmt.parseInt(usize, line, 10);
       
        try numbers.append(number);
    }
    
    print("answer: {}\n", .{ search() });
}

fn search() usize
{
    for (25..numbers.items.len) | index |
    {
        if (! checkNumberAt(index)) { return numbers.items[index]; }
    }
    unreachable;
}

fn checkNumberAt(index: usize) bool
{
    const target = numbers.items[index];
 
    for (index-25..index) | indexA |
    {
        for (indexA+1..index) | indexB |
        {
            if (numbers.items[indexA] + numbers.items[indexB] == target) { return true; }
        }
    }
    return false;
}

