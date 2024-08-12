//! solution for https://adventofcode.com/2015/day/6 part 2

const std = @import("std");

const print = std.debug.print;

const dimension = 1000;

var table = [1]u8{ 0 } ** (dimension * dimension);

const Kind = enum { turnOn, turnOff, toggle };
    

pub fn main() !void
{
    const rawData: []const u8 = @embedFile("day06-input.txt");

    const data = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");

    while (lines.next()) |line| 
    {
        try processDataLine(line);
    }
    
    print("answer: {}\n", .{ countLightsOn() });
}

fn processDataLine(line: []const u8) !void
{
    var tokens = std.mem.tokenizeSequence(u8, line, " ");
    
    var kind = Kind.toggle;
    {
        var token = tokens.next().?;
        
        if (std.mem.eql(u8, token, "turn")) 
        { 
            token = tokens.next().?;
            kind = if (std.mem.eql(u8, "on", token)) .turnOn else .turnOff;
        }
    }

    var left: u32 = 0;
    var top: u32 = 0;
    {
        const token = tokens.next().?;
        var chunks = std.mem.splitAny(u8, token, ",");
        
        left = try std.fmt.parseInt(u32, chunks.next().?, 10);
        top  = try std.fmt.parseInt(u32, chunks.next().?, 10);
    }

    _ = tokens.next(); // through

    var right: u32 = 0;
    var bottom: u32 = 0;
    {
        const token = tokens.next().?;
        var chunks = std.mem.splitAny(u8, token, ",");
        
        right = try std.fmt.parseInt(u32, chunks.next().?, 10);
        bottom = try std.fmt.parseInt(u32, chunks.next().?, 10);
    }

    applyCommand(kind, left, top, right, bottom);
}

fn applyCommand(kind: Kind, left: u32, top: u32, right: u32, bottom: u32) void
{
    var x: u32 = left;
    while (x <= right) : (x += 1)
    {
        var y: u32 = top;
        while (y <= bottom) : (y += 1)
        {
            const index: u32 = x + (y * dimension);
            switch (kind)
            {
                .turnOn  => table[index] += 1,
                .turnOff => if (table[index] != 0) { table[index] -= 1; },
                .toggle  => table[index] += 2,
            }
        }
    }
}

fn countLightsOn() u32
{
    var count: u32 = 0;
    for (table) |light| { count += light; }
    return count;
}

