//! solution for https://adventofcode.com/2020/day/12 part 1

const std = @import("std");

const print = std.debug.print;

// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
// const allocator = arena.allocator();

const Direction = enum
{
    north,
    south,
    east,
    west,
};

var shipRow: i32 = 0;
var shipCol: i32 = 0;

var facing: Direction = .east;


pub fn main() !void
{
 // defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day12-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var rawLines = std.mem.splitSequence(u8, data, "\n"); 
    
    while (rawLines.next()) | rawLine | 
    { 
        const line = std.mem.trimRight(u8, rawLine, " ");

        sail(line);
    }

    print("answer: {}\n", .{ @abs(shipRow) + @abs(shipCol) });
}

///////////////////////////////////////////////////////////////////////////////

fn sail(token: []const u8) void
{ 
    const amount: i32 = std.fmt.parseInt(i32, token[1..], 10) catch @panic("error in sail");
    
    switch (token[0])
    {    
        'N' => shipRow -= amount,
        'S' => shipRow += amount,
        'E' => shipCol += amount,
        'W' => shipCol -= amount,
        'L' => rotateLeft(amount),
        'R' => rotateRight(amount),
        'F' => advance(amount),
        else => unreachable,
    }
}
 
fn advance(amount: i32) void
{
    switch (facing)
    {    
        .north => shipRow -= amount,
        .south => shipRow += amount,
        .east =>  shipCol += amount,
        .west =>  shipCol -= amount,
    }
}

fn rotateLeft(amount: i32) void
{
    var turns: i32 = amount;

    while (turns > 0) { rotateLeftCore(); turns -= 90; }
} 

fn rotateRight(amount: i32) void
{
    var turns: i32 = amount;

    while (turns > 0) { rotateRightCore(); turns -= 90; }
} 

fn rotateLeftCore() void
{
    facing = switch (facing)
    {
        .north => .west,
        .west  => .south,
        .south => .east,
        .east  => .north,
    };
}

fn rotateRightCore() void 
{
    facing = switch (facing)
    {
        .north => .east,
        .east  => .south,
        .south => .west,
        .west  => .north,
    };
}

