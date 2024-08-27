//! solution for https://adventofcode.com/2020/day/13 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var buses = std.ArrayList(usize).init(allocator);


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day13-input.txt");
    
    var parts = std.mem.tokenizeAny(u8, rawData, "\n "); 
    
    _ = parts.next();
    const part2 = parts.next().?;
    
    var tokens = std.mem.tokenizeAny(u8, part2, ",");
        
    while (tokens.next())  | token |
    {
        if (token[0] == 'x') { try buses.append(1); continue; }

        const bus = try std.fmt.parseInt(usize, token, 10);
        
        try buses.append(bus);
    }

    print("answer: {}\n", .{ search() });
}

///////////////////////////////////////////////////////////////////////////////

// this algorithm was copied from:
// https://github.com/alvin-the-programmer/advent-of-code-2020/blob/main/walkthrough/d13/part2.js

fn search() usize
{
    var time: usize = 0;

    var stepSize: usize = buses.items[0];

    for (1..buses.items.len) | index |
    {
        const bus = buses.items[index];

        while ((time + index) % bus != 0) { time += stepSize; }

        stepSize *= bus; // need not to be LCM because all buses are prime numbers
    }
    
    return time;
}

