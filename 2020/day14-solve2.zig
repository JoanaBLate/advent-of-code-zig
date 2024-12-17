//! solution for https://adventofcode.com/2020/day/14 part 2

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

    const addressString = tokens.next().?;
    
    const valueString = tokens.next().?;

    const addressDecimal: usize = try std.fmt.parseInt(usize, addressString, 10);
    
    const value: usize = try std.fmt.parseInt(usize, valueString, 10);

    var buffer: [36]u8 = undefined;

    const adressBinary: []u8 = try std.fmt.bufPrint(&buffer, "{b}", .{ addressDecimal });

    const pad: []const u8 = zeroes36[0..36-adressBinary.len];

    var addressMasked = try std.fmt.allocPrint(allocator, "{s}{s}", .{ pad, adressBinary }); 

    for (0..36) | index |
    {
        if (mask[index] != '0') { addressMasked[index] = mask[index]; }
    }  
        
    editMemoryThis(addressMasked, value);
}

fn editMemoryThis(addressMasked: []u8, value: usize) void
{    
    const indexOfX = std.mem.indexOfScalar(u8, addressMasked, 'X');
        
    if (indexOfX == null) // no more replacements to do
    { 
        const key = std.fmt.allocPrint(allocator, "{s}", .{ addressMasked }) catch @panic("error in editMemoryThis");
        
        memory.put(key, value) catch @panic("error in editMemoryThis");
         
        return; 
    }
    
    var a = std.fmt.allocPrint(allocator, "{s}", .{ addressMasked }) catch @panic("error in editMemoryThis");
    var b = std.fmt.allocPrint(allocator, "{s}", .{ addressMasked }) catch @panic("error in editMemoryThis");

    a[indexOfX.?] = '0';
    b[indexOfX.?] = '1';
        
    editMemoryThis(a, value);
    editMemoryThis(b, value);
}

fn sumMemory() usize
{
    var sum: usize = 0;
    
    var iterator = memory.iterator();
    
    while (iterator.next()) | entry | { sum += entry.value_ptr.*; }
    
    return sum;
}

