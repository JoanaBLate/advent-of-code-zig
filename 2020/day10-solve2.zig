//! solution for https://adventofcode.com/2020/day/10 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();


const Adapter = struct
{
    jolts: u32,
    paths: usize = 0, // the number of paths to reach this adapter
};

var adapters: std.ArrayList(Adapter) = undefined;


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day10-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var rawLines = std.mem.splitSequence(u8, data, "\n"); 
    
    var rawAdapters = try std.ArrayList(u32).initCapacity(allocator, 150);
    
    while (rawLines.next()) | rawLine | 
    { 
        const line = std.mem.trimRight(u8, rawLine, " ");
       
        const number: u32 = try std.fmt.parseInt(u32, line, 10);
       
        try rawAdapters.append(number);
    }
    
    const array = rawAdapters.items;

    sort(array);

    adapters = try std.ArrayList(Adapter).initCapacity(allocator, 150);
    
    try adapters.append(Adapter { .jolts = 0, . paths = 1 }); // the zero start will easy the search
    
    for (array) | jolts | { try adapters.append(Adapter{ .jolts = jolts }); }

    fillNodes();

    const lastAdapter = adapters.getLast();
    
    print("answer: {}\n", .{ lastAdapter.paths });
}

// sort ///////////////////////////////////////////////////////////////////////

fn sort(array: []u32) void
{   
    while ( sortOnce(array)) { }
}

fn sortOnce(array: []u32) bool
{
    var changed = false;
    
    for (0..array.len-1) | indexA |
    {
        for (indexA..array.len) | indexB |
        {
            const a = array[indexA];
            const b = array[indexB];
            
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
    const baseAdapter = adapters.items[baseIndex];
    
    const maxIndex: usize = adapters.items.len - 1;

    for (baseIndex+1..baseIndex+4) | index |
    {
        if (index > maxIndex) { return; }
        
        var currentAdapter = &adapters.items[index];

        if (currentAdapter.jolts - baseAdapter.jolts > 3) { return; }
        
        currentAdapter.paths += baseAdapter.paths;
    }
}

