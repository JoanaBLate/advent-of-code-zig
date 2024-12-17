//! solution for https://adventofcode.com/2020/day/05 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var allSeats = std.ArrayList(u32).init(allocator);


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day05-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitSequence(u8, data, "\n"); 
    
    while (lines.next()) | rawLine | 
    { 
        const line = std.mem.trimRight(u8, rawLine, " ");
        try processLine(line);
    }
    
    sortAllSeats();
    
    print("answer: {any}\n", .{ findFreeSeat() });
}

fn processLine(line: []const u8) !void
{
    const row = processRange(line[0..7], 0, 127);
    
    const col = processRange(line[7..], 0, 7);
    
    const seat = row * 8 + col;
    
    try allSeats.append(seat);
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

fn sortAllSeats() void
{
    while (sortAllSeatsCore()) { }
}

fn sortAllSeatsCore() bool
{
    var changed = false;
    
    var items = allSeats.items;
    
    for (0..items.len-1) | index |
    {
        if (items[index] <= items[index + 1]) { continue; }
        
        const temp = items[index];
        items[index] = items[index + 1];
        items[index + 1] = temp;
        changed = true;
    }
    return changed;
}

fn findFreeSeat() u32
{
    for (0..allSeats.items.len-1) | index |
    {
        const current = allSeats.items[index];
        const next = allSeats.items[index+1];

        if (next - current == 2) { return current + 1; }
    }
    unreachable;
}

