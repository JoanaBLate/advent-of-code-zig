//! solution for https://adventofcode.com/2015/day/8 part 1

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

fn processDataLine(line: []const u8) void
{    
    difference += 2; // the 2 delimiting double quotes
    
    var index: u8 = 0;
    while (index < line.len) : (index += 1)
    {
        if (line[index] != '\\') { continue; }
        
        difference += 1;
        index += 1;
    
        if (line[index] == 'x') { difference += 2; index += 2; }
    }
}

