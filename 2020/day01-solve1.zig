//! solution for https://adventofcode.com/2020/day/01 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day01-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");
    
    var numbers = try std.ArrayList(u32).initCapacity(allocator, 100);
    
    while (lines.next()) | rawLine | 
    { 
        const line = std.mem.trimRight(u8, rawLine, " ");
    
        const number = try std.fmt.parseInt(u32, line, 10);
    
        try numbers.append(number);
    }
    
    print("answer: {}\n", .{ getResult(numbers) });
}   
 
fn getResult(numbers: std.ArrayList(u32)) u32
{   
    for (0..numbers.items.len) | indexA |
    {
        for (indexA+1..numbers.items.len) | indexB |
        {
            const numberA = numbers.items[indexA];
            const numberB = numbers.items[indexB];
            
            if (numberA + numberB == 2020) { return numberA * numberB; }
        }
    }  
    
    unreachable;      
}

