//! solution for https://adventofcode.com/2015/day/3 part 2

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

    var position = Position{ .row = 0, .col = 0 };
    
    var santaRow: i32 = 0;
    var santaCol: i32 = 0;
    
    var robotRow: i32 = 0;
    var robotCol: i32 = 0;
    
    var map = std.AutoHashMap(Position, bool).init(allocator);
    
    try map.put(position, true);
    
    var count: u32 = 1;
    
    var isSantaTurn = false;
    
    for (data) |item| 
    {
        isSantaTurn = ! isSantaTurn;
        
        var deltaRow: i32 = 0;
        var deltaCol: i32 = 0;
        
        switch (item)
        {
            '^' => deltaRow = -1,
            'v' => deltaRow =  1,
            '<' => deltaCol = -1,
            '>' => deltaCol =  1,
            else => { },
        } 
        
        if (isSantaTurn)
        {
            santaRow += deltaRow;
            santaCol += deltaCol;
            position = Position{ .row = santaRow, .col = santaCol };
        }
        else 
        {
            robotRow += deltaRow;
            robotCol += deltaCol;
            position = Position{ .row = robotRow, .col = robotCol };
        }

        const value = map.get(position);
        if (value != null) { continue; }
        try map.put(position, true);
        count += 1;
    }
    
    print("answer: {}\n", .{ count });
}

