//! solution for https://adventofcode.com/2020/day/10 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var adapters: std.ArrayList(usize) = undefined;
var nodes: std.ArrayList(usize) = undefined; // stores the number of many ways to reach this node/adapter


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day10-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var rawLines = std.mem.splitSequence(u8, data, "\n"); 
    
    adapters = try std.ArrayList(usize).initCapacity(allocator, 150);
    nodes = try std.ArrayList(usize).initCapacity(allocator, 150);
    
    try adapters.append(0); // the zero start will
    try nodes.append(1);    // easy the search later
    
    while (rawLines.next()) | rawLine | 
    { 
        const line = std.mem.trimRight(u8, rawLine, " ");
       
        const number: usize = try std.fmt.parseInt(usize, line, 10);
       
        try adapters.append(number);
        try nodes.append(0);
    }
    
    sort();
    
    fillNodes();
    
    print("answer: {}\n", .{ nodes.getLast() });
}

// sort ///////////////////////////////////////////////////////////////////////

fn sort() void
{
    const array = adapters.items[0..];    
    while ( sortOnce(array)) { }
}

fn sortOnce(array: []usize) bool
{
    var changed = false;
    
    for (0..array.len-1) | indexA |
    {
        for (indexA..array.len) | indexB |
        {
            const a: usize = array[indexA];
            const b: usize = array[indexB];
            
            if (a <= b) { continue; }

            changed = true;
            array[indexA] = b;
            array[indexB] = a;
        }
    }
    return changed;
}

///////////////////////////////////////////////////////////////////////////////

fn fillNodes() void
{       
    for (0..adapters.items.len) | index | { fillNodesWith(index); }
}

fn fillNodesWith(baseIndex: usize) void
{       
    const baseValue: usize = adapters.items[baseIndex];
    const baseNode:  usize = nodes.items[baseIndex];
    
    const maxIndex:usize = adapters.items.len - 1;
    
    for (baseIndex+1..baseIndex+4) | index |
    {
        if (index > maxIndex) { return; }
        
        const value = adapters.items[index];
        
        if (value - baseValue > 3) { return; }
        
        nodes.items[index] += baseNode;
    }
}

