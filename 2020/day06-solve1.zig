//! solution for https://adventofcode.com/2020/day/06 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var count: u32 = 0;


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day06-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var groups = std.mem.splitSequence(u8, data, "\n\n"); 
    
    while (groups.next()) | rawGroup | 
    { 
        const group = std.mem.trimRight(u8, rawGroup, " ");
        try processGroup(group);
    }
    
    print("answer: {}\n", .{ count });
}

fn processGroup(group: []const u8) !void
{
    var map = std.StringHashMap(bool).init(allocator);
    
    var lines = std.mem.splitAny(u8, group, "\n"); 
    
    while (lines.next()) | rawLine |
    {
        const line: []const u8 = std.mem.trimRight(u8, rawLine, " ");

        for (0..line.len) | index | 
        {            
            try map.put(line[index..index+1], true); 
        }    
    }
    
    count += map.count();
}

