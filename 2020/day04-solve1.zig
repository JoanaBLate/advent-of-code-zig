//! solution for https://adventofcode.com/2020/day/04 part 1

const std = @import("std");

const print = std.debug.print;

// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
// const allocator = arena.allocator();


pub fn main() !void
{
 // defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day04-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lineGroups = std.mem.splitSequence(u8, data, "\n\n");
    
    var count: u32 = 0;
    
    while (lineGroups.next()) | lineGroup | 
    { 
        if (isValidPassport(lineGroup)) { count += 1; }
    }
        
    print("answer: {}\n", .{ count });
}

fn isValidPassport(lineGroup: []const u8) bool
{
    var count: u32 = 0;
    
    var tokens = std.mem.splitAny(u8, lineGroup, " \n");
        
    while (tokens.next()) | token |
    {
        const fieldName: []const u8 = token[0..3];
        
        if (std.mem.eql(u8, fieldName, "cid")) { continue; }
        
        count += 1; 
    }

    return count == 7;
}

