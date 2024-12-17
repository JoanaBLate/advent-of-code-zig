//! solution for https://adventofcode.com/2015/day/3 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();
    
const Position = struct { row: i32 = 0, col: i32 = 0 };


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day03-input.txt");

    const data = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var row: i32 = 0;
    var col: i32 = 0;

    var map = std.AutoHashMap(Position, bool).init(allocator);
    
    try map.put(.{ .row = 0, .col = 0 }, true);
    
    var count: u32 = 1;
    
    for (data) |item| 
    {
        switch (item)
        {
            '^' => row -= 1,
            'v' => row += 1,
            '<' => col -= 1,
            '>' => col += 1,
            else => { },
        } 
        const position = Position{ .row = row, .col = col };
        
        const value = map.get(position);
        if (value != null) { continue; }
        try map.put(position, true);
        count += 1;
    }
    
    print("answer: {}\n", .{ count });
}

