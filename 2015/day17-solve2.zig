//! solution for https://adventofcode.com/2015/day/17 part 2

//! EXPECTING **20** BOTTLES!

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const wholeVolume: u32 = 150;

const length: u32 = 20;

var bottles: [20]u32 = [1]u32{0} ** length;

// 1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288
var bottlePows: [20]u32 = [1]u32{0} ** length;

// The puzzles says that two bottles of the same capacity are considered different.
// So, we are going to use the POSITION of the bottle in the list for its id.

// We can think the list of bottles as an array of booleans (filled bottle vs not filled bottle).
// For example: [ true, false, false, true, true... ] or [ 1, 0, 0, 1, 1...]
// We can associate a binary number to each sequence (10011...).
// And we can work with the decimalrepresentatoin of this number.
// Considering 20 bottles, the number of possible combinations is 2 at power 20 (1048576).

var maxDecimal: u32 = std.math.pow(u32, 2, length);

var numberOfMinimumMatches: u32 = 20;

    
pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day17-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");

    var index: u32 = 0;
    while (lines.next()) | line | 
    { 
        bottles[index] = try std.fmt.parseInt(u8, line, 10); 
        
        bottlePows[index] = std.math.pow(u32, 2, index); 
        
        index += 1;
    }

    try tryFilling();

    print("answer: {d}\n", .{ numberOfMinimumMatches });
}

fn tryFilling() !void
{
    var map = std.AutoHashMap(u32, u32).init(allocator);
    
    var n: u32 = 0;
    while (n < 20) : (n += 1) { try map.put(n, 0); }
    
    var decimal: u32 = 0;
    while (decimal <= maxDecimal) : (decimal += 1)
    {
        var sum: u32 = 0;
        
        var count: u32 = 0;
        
        for (0..20) | index |
        {
            const bottlePow = bottlePows[index];
            
            if (decimal & bottlePow == 0) { continue; } // bitwise operation
            
            count += 1;
            
            sum += bottles[index];
        
            if (sum > wholeVolume) { break; }
        }
        
        if (sum != wholeVolume) { continue; }
        
        const current = map.get(count).?;
        
        try map.put(count, current + 1);
    }
    
    var m: u32 = 0;
    while (m < 20) : (m += 1) 
    {
        const count = map.get(m).?;
        
        if (count != 0) { numberOfMinimumMatches = count; return; }
    }
}

