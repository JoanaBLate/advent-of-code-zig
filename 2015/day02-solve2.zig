//! solution for https://adventofcode.com/2015/day/2 part 2

const std = @import("std");

const print = std.debug.print;

var totalRibbon: u32 = 0;


pub fn main() !void
{
    const rawData: []const u8 = @embedFile("day02-input.txt");
    
    const data = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");
    
    while (lines.next()) |line| 
    {
        try processDataLine(line);
    }
    
    print("answer: {}\n", .{ totalRibbon });
}

fn processDataLine(line: []const u8) !void
{
    var chunks = std.mem.splitAny(u8, line, "x");
    
    const l = try std.fmt.parseInt(u32, chunks.next().?, 10); // length
    const w = try std.fmt.parseInt(u32, chunks.next().?, 10); // width
    const h = try std.fmt.parseInt(u32, chunks.next().?, 10); // height

    const allSides = l + w + h;
    
    var greatest: u32 = 0;

    if (l > greatest) { greatest = l; }
    if (w > greatest) { greatest = w; }
    if (h > greatest) { greatest = h; }
    
    totalRibbon += (2 * (allSides - greatest)) + (l * w * h);
}

