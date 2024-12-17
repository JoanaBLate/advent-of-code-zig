//! solution for https://adventofcode.com/2015/day/4 part 1

const std = @import("std");
const md5 = @import("md5.zig");

const print = std.debug.print;
    
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day04-input.txt");

    const secretKey = std.mem.trimRight(u8, rawData, "\n\r ");

    var n: u64 = 0;    
    while (true) : (n += 1)
    {
        const str = try std.fmt.allocPrint(allocator, "{s}{d}", .{ secretKey, n });
        
        var hashed: [16]u8 = undefined;
        _ = md5.Md5.hash(str, &hashed, .{});
   
        if (hashed[0] != 0) { continue; } // hexa: 00
        if (hashed[1] != 0) { continue; } // hexa: 00
        if (hashed[2] >  9) { continue; } // decimal > 9 means its hexa representation doesn't start with '0'
    
       print("answer: {}\n", .{ n });
       
       break;
    }
}

