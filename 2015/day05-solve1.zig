//! solution for https://adventofcode.com/2015/day/5 part 1

const std = @import("std");

const print = std.debug.print;

var count: u32 = 0;
    

pub fn main() !void
{
    const rawData: []const u8 = @embedFile("day05-input.txt");

    const data = std.mem.trimRight(u8, rawData, "\n\r ");

    var lines = std.mem.splitAny(u8, data, "\n");
    
    while (lines.next()) |line| 
    {
        processDataLine(line);
    }
    
    print("answer: {}\n", .{ count });
}

fn processDataLine(line: []const u8) void
{
    var vowels: u32 = 0;
    
    for (0..line.len) |index| 
    {        
        if (line[index] == 'a') { vowels += 1; continue; }
        if (line[index] == 'e') { vowels += 1; continue; }
        if (line[index] == 'i') { vowels += 1; continue; }
        if (line[index] == 'o') { vowels += 1; continue; }
        if (line[index] == 'u') { vowels += 1; continue; }
    }
    
    if (vowels < 3) { return; }
    
    var gotPair = false;
    
    for (0..line.len-1) |index| // ignores the last item
    {        
        if (line[index] == line[index + 1]) { gotPair = true; break; }
    }
    
    if (! gotPair) { return; }
        
    if (std.mem.indexOf(u8, line, "ab") != null) { return; }
    if (std.mem.indexOf(u8, line, "cd") != null) { return; }
    if (std.mem.indexOf(u8, line, "pq") != null) { return; }
    if (std.mem.indexOf(u8, line, "xy") != null) { return; }
    
    count += 1;
}

