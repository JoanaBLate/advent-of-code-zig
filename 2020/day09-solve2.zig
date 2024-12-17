//! solution for https://adventofcode.com/2020/day/09 part 2

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
    
    const target = search1();
    
    print("answer: {}\n", .{ search2(target) });
}

///////////////////////////////////////////////////////////////////////////////

fn search1() usize
{
    for (25..numbers.items.len) | index |
    {
        if (! checkNumberAt1(index)) { return numbers.items[index]; }
    }
    unreachable;
}

fn checkNumberAt1(index: usize) bool
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

///////////////////////////////////////////////////////////////////////////////

fn search2(target: usize) usize
{
    for (0..numbers.items.len) | index |
    {
        const result = checkNumberAt2(target, index);
        
        if (result != 0) { return result; }
    }
    unreachable;
}

fn checkNumberAt2(target: usize, startIndex: usize) usize
{
    var sum: usize = 0;
    
    var index: usize = startIndex;
    
    while (true) : (index += 1)
    {
        sum += numbers.items[index];
        
        if (sum > target) { return 0; }
        
        if (sum == target) { return search2Range(startIndex, index); }
    }
    
    unreachable;
}

fn search2Range(startIndex: usize, endIndex: usize) usize
{
    var min: usize = 999_999_999;
    var max: usize = 0;

    for (startIndex..endIndex+1) | index |
    {
        const number = numbers.items[index];
        
        if (number < min) { min = number; }
        if (number > max) { max = number; }
    }

    return min + max;
}

