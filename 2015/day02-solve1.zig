//! solution for https://adventofcode.com/2015/day/2 part 1

const std = @import("std");

const print = std.debug.print;

var totalPaper: u32 = 0;


pub fn main() !void
{
    const rawData: []const u8 = @embedFile("day02-input.txt");

    const data = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");
    
    while (lines.next()) |line| 
    {
        try processDataLine(line);
    }
    
    print("answer: {}\n", .{ totalPaper });
}

fn processDataLine(line: []const u8) !void
{
    var chunks = std.mem.splitAny(u8, line, "x");
    
    const l = try std.fmt.parseInt(u32, chunks.next().?, 10); // length
    const w = try std.fmt.parseInt(u32, chunks.next().?, 10); // width
    const h = try std.fmt.parseInt(u32, chunks.next().?, 10); // height

    const area1 = l * w;
    const area2 = l * h;
    const area3 = h * w;
    
    var least: u32 = area1 + area2 + area3;

    if (area1 < least) { least = area1; }
    if (area2 < least) { least = area2; }
    if (area3 < least) { least = area3; }
    
    totalPaper += (2 * area1) + (2 * area2) + (2 * area3) + least;
}

