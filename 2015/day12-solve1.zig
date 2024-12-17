//! solution for https://adventofcode.com/2015/day/12 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();


pub fn main() !void
{
    defer arena.deinit();

    const rawData: []const u8 = @embedFile("day12-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");

    var sum: i32 = 0;
    var token: []u8 = "";
        
    for (data) |c|
    {
        if (c == '-') { token = try std.fmt.allocPrint(allocator, "{s}", .{ "-" }); continue; }
        
        if (c >= '0'  and  c <= '9') 
        { 
            token = try std.fmt.allocPrint(allocator, "{s}{c}", .{ token, c });    
            continue;
        }
        
        if (token.len != 0) 
        { 
            sum += try std.fmt.parseInt(i32, token, 10); 
            token = "";
        }
    }
        
    if (token.len != 0) 
    { 
        sum += try std.fmt.parseInt(i32, token, 10); 
        token = "";
    }
        
    print("answer: {d}\n", .{ sum });
}

