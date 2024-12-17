//! solution for https://adventofcode.com/2020/day/06 part 2

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
    var map = std.StringHashMap(u32).init(allocator);
    
    var lines = std.mem.splitAny(u8, group, "\n"); 
    
    var people: u32 = 0;
    
    while (lines.next()) | rawLine |
    {
        people += 1;
    
        const line: []const u8 = std.mem.trimRight(u8, rawLine, " ");

        for (0..line.len) | index | 
        {            
            const key: []const u8 = line[index..index+1];
            
            const current = map.get(key);
            
            if (current == null) { try map.put(key, 1); } else { try map.put(key, current.? + 1); }
        }    
    }
    
    var thisCount: u32 = 0;
    var iterator = map.valueIterator();
    
    while (iterator.next()) | pointerToValue | 
    { 
        if (pointerToValue.* == people) { thisCount += 1; }
    }
    
    count += thisCount;
}

