//! solution for https://adventofcode.com/2015/day/8 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();
     
var difference: u32 = 0;

pub fn main() !void
{
    defer arena.deinit();       

    const rawData: []const u8 = @embedFile("day08-input.txt");

    const data = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");
    
    while (lines.next()) |line| 
    {
        processDataLine(line);
    }
        
    print("answer: {}\n", .{ difference });
}

fn processDataLine(srcLine: []const u8) void
{    
    const line = srcLine[1..srcLine.len-1]; // excludes delimiters

    difference += 4; // for the 2 new delimiters
    
    var index: u8 = 0;
    while (index < line.len) : (index += 1)
    {
        if (line[index] != '\\') { continue; }
        
        difference += 1;
        
        if (index == line.len - 1) { break; }
        
        if (line[index + 1] == '"') { difference += 1; }
    }
}

