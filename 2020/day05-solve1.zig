//! solution for https://adventofcode.com/2020/day/05 part 1

const std = @import("std");

const print = std.debug.print;

// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
// const allocator = arena.allocator();

var highestSeat: u32 = 0;

pub fn main() !void
{
 // defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day05-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitSequence(u8, data, "\n");
    
    while (lines.next()) | rawLine | 
    { 
        const line = std.mem.trimRight(u8, rawLine, " ");
        processLine(line);
    }
        
    print("answer: {}\n", .{ highestSeat });
}

fn processLine(line: []const u8) void
{
    const row = processRange(line[0..7], 0, 127);
    
    const col = processRange(line[7..], 0, 7);
    
    const seat = row * 8 + col;
    
   if (seat > highestSeat) { highestSeat = seat; }
} 

fn processRange(token: []const u8, min: u32, max: u32) u32
{
    const isHigh = (token[0] == 'B'  or  token[0] == 'R');
    const newToken = token[1..];
    const length: u32 = max - min + 1;     
    const newLength: u32 = length / 2;
    
    if (isHigh)
    {
        if (length == 2) { return max; } 
        
        const newMin: u32 = max - newLength + 1;
        return processRange(newToken, newMin, max);
    }    
    else // is low
    {
        if (length == 2) { return min;  }
        
        const newMax: u32 = min + newLength - 1;
        return processRange(newToken, min, newMax);
    } 
}

