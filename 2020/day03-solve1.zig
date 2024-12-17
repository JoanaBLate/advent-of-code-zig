//! solution for https://adventofcode.com/2020/day/03 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var map: std.ArrayList([]const u8) = undefined;


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day03-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");
    
    map = try std.ArrayList([]const u8).initCapacity(allocator, 350);
    
    while (lines.next()) | rawLine | 
    { 
        const line = std.mem.trimRight(u8, rawLine, " ");
    
        try map.append(line);
    }
        
    print("answer: {}\n", .{ travel() });
}

fn travel() u32
{
    const width:  u32 = @intCast(map.items[0].len);
    const height: u32 = @intCast(map.items.len);
    
    // using base one index
    
    var row: u32 = 1;
    var col: u32 = 1; // virtual column
    var count: u32 = 0;

    while (true)     
    {
        row += 1;
        if (row > height) { return count; }
        
        col += 3;
        if (col > width) { col -= width; }
    
        if (map.items[row-1][col-1] == '#') { count += 1; }    
    }
    unreachable;
}

