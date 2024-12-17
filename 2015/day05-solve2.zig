//! solution for https://adventofcode.com/2015/day/5 part 2

const std = @import("std");

const print = std.debug.print;

var count: u32 = 0;
    

pub fn main() !void
{
    const rawData: []const u8 = @embedFile("day05-input.txt");

    const data = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");

    while (lines.next()) |line| 
    {
        processDataLine(line);
    }
    
    print("answer: {}\n", .{ count });
}

fn processDataLine(line: []const u8) void
{    
    var twoPairsOk = false;
    
    for (0..line.len-3) |index| // ignores the last 3 items
    {        
        if (hasTwoPairs(line, index)) { twoPairsOk = true; break; }
    }
    
    if (! twoPairsOk) { return; }
    
    
    var trioOk = false;
    
    for (0..line.len-2) |index| // ignores the last 2 items
    {        
        if (line[index] == line[index + 2]) { trioOk = true; break; }
    }
    
    if (! trioOk) { return; }
    
    count += 1;
}

fn hasTwoPairs(line: []const u8, index: usize) bool
{ 
    const pair = line[index..index+2]; // two items
    
    const lastIndex = std.mem.lastIndexOf(u8, line, pair);
    
    return if (lastIndex.? - index < 2) false else true;
}

