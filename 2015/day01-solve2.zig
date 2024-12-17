//! solution for https://adventofcode.com/2015/day/1 part 2

const std = @import("std");

const print = std.debug.print;


pub fn main() void
{
    const rawData: []const u8 = @embedFile("day01-input.txt");

    const data = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var floor: i32 = 0;
    
    const max = data.len;
    
    var index: usize = 0;
    while (index < max) : (index += 1)
    {
        floor += if (data[index] == '(') 1 else -1;
        if (floor == -1) { break; }
    }
    
    print("answer: {}\n", .{ index + 1 });
}
