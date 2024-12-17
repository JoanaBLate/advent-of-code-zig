//! solution for https://adventofcode.com/2020/day/14 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var memory = std.StringHashMap(usize).init(allocator);


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day14-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var rawLines = std.mem.splitAny(u8, data, "\n"); 
    
    var mask: []const u8 = "";
        
    while (rawLines.next())  | rawLine |
    {
        const line = std.mem.trimRight(u8, rawLine, " ");
        
        if (line[1] == 'a') { mask = line[7..]; } else { try editMemory(mask, line); }
    }

    print("answer: {}\n", .{ sumMemory() });
}

///////////////////////////////////////////////////////////////////////////////

fn editMemory(mask: []const u8, line: []const u8) !void
{
    const zeroes36: [36]u8 = [1]u8{ '0' } ** 36;

    var tokens = std.mem.splitSequence(u8, line[4..], "] = ");

    const address = tokens.next().?;
    
    const decimalString = tokens.next().?;

    const decimal: u32 = try std.fmt.parseInt(u32, decimalString, 10);

    var buffer: [36]u8 = undefined;

    const binary: []u8 = try std.fmt.bufPrint(&buffer, "{b}", .{ decimal });

    const pad: []const u8 = zeroes36[0..36-binary.len];

    var binary36 = try std.fmt.allocPrint(allocator, "{s}{s}", .{ pad, binary }); 
    
    for (0..36) | index |
    {
        if (mask[index] != 'X') { binary36[index] = mask[index]; }
    }  
    
    const value: usize = try std.fmt.parseInt(usize, binary36, 2);
    
    try memory.put(address, value);
}

fn sumMemory() usize
{
    var sum: usize = 0;
    
    var iterator = memory.iterator();
    
    while (iterator.next()) | entry | { sum += entry.value_ptr.*; }
    
    return sum;
}

