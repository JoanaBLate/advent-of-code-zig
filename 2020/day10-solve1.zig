//! solution for https://adventofcode.com/2020/day/10 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var adapters: std.ArrayList(u32) = undefined;


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day10-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var rawLines = std.mem.splitSequence(u8, data, "\n"); 
    
    adapters = try std.ArrayList(u32).initCapacity(allocator, 150);
    
    while (rawLines.next()) | rawLine | 
    { 
        const line = std.mem.trimRight(u8, rawLine, " ");
       
        const number: u32 = try std.fmt.parseInt(u32, line, 10);
       
        try adapters.append(number);
    }
    
    sort();
    
    print("answer: {}\n", .{ search(adapters.items) });
}

fn sort() void
{
    const array = adapters.items[0..];    
    while ( sortOnce(array)) { }
}

fn sortOnce(array: []u32) bool
{
    var changed = false;
    
    for (0..array.len-1) | indexA |
    {
        for (indexA..array.len) | indexB |
        {
            const a: u32 = array[indexA];
            const b: u32 = array[indexB];
            
            if (a <= b) { continue; }

            changed = true;
            array[indexA] = b;
            array[indexB] = a;
        }
    }
    return changed;
}

///////////////////////////////////////////////////////////////////////////////

fn search(array: []u32) u32
{
    var deltaOne: u32 = 0;
    var deltaThree: u32 = 1; // '1' for the difference to device
    
    if (array[0] == 1  or  array[0] == 3) { deltaOne = 1; } // diference to the outlet
        
    for (0..array.len-1) | index |
    {
        const delta: u32 = array[index+1] - array[index];
        
        if (delta == 1) { deltaOne += 1; continue; }
        if (delta == 3) { deltaThree += 1; continue; }
    }
    return deltaOne * deltaThree;
}

