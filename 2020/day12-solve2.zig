//! solution for https://adventofcode.com/2020/day/12 part 2

const std = @import("std");

const print = std.debug.print;

// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
// const allocator = arena.allocator();


var shipRow: i32 = 0;
var shipCol: i32 = 0;

var wayPointRow: i32 = -1;
var wayPointCol: i32 = 10;


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
        'N' => wayPointRow -= amount,
        'S' => wayPointRow += amount,
        'E' => wayPointCol += amount,
        'W' => wayPointCol -= amount,
        'L' => rotateWayPointLeft(amount),
        'R' => rotateWayPointRight(amount),
        'F' => advance(amount),
        else => unreachable,
    }
}
 
fn advance(amount: i32) void
{
    shipRow += amount * wayPointRow;
    shipCol += amount * wayPointCol;
}

fn rotateWayPointLeft(amount: i32) void
{
    var turns: i32 = amount;

    while (turns > 0) { rotateWayPointLeftCore(); turns -= 90; }
} 

fn rotateWayPointRight(amount: i32) void
{
    var turns: i32 = amount;

    while (turns > 0) { rotateWayPointRightCore(); turns -= 90; }
} 

fn rotateWayPointLeftCore() void
{
    var newRow: i32 = 0;
    var newCol: i32 = 0;
    
    if (wayPointRow < 0) { // north
    
        newCol = wayPointRow; // west  
    }
    else if (wayPointRow > 0) { // south
    
        newCol = wayPointRow; // east
    }
    
    if (wayPointCol > 0) { // east
    
        newRow = -wayPointCol; // north    
    }
    else if (wayPointCol < 0) { // west
    
        newRow = -wayPointCol; // south
    }
    
    wayPointRow = newRow;
    wayPointCol = newCol;
}

fn rotateWayPointRightCore() void 
{
    var newRow: i32 = 0;
    var newCol: i32 = 0;
    
    if (wayPointRow < 0) { // north
    
        newCol = - wayPointRow; // east  
    }
    else if (wayPointRow > 0) { // south
    
        newCol = - wayPointRow; // west
    }
    
    if (wayPointCol > 0) { // east
    
        newRow = wayPointCol; // south
    }
    else if (wayPointCol < 0) { // west
    
        newRow = wayPointCol; // north
    }
    
    wayPointRow = newRow;
    wayPointCol = newCol;
}

