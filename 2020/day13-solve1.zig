//! solution for https://adventofcode.com/2020/day/13 part 1

const std = @import("std");

const print = std.debug.print;

// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
// const allocator = arena.allocator();


pub fn main() !void
{
 // defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day13-input.txt");
    
    var parts = std.mem.tokenizeAny(u8, rawData, "\n "); 
    
    const part1 = parts.next().?;
    const part2 = parts.next().?;
    
    const timeStamp: u32 = try std.fmt.parseInt(u32, part1, 10);
    
    var tokens = std.mem.tokenizeAny(u8, part2, ",x");
    
    var bestBus: u32 = undefined;
    var bestDelay: u32 = timeStamp; // just a big number 

    var bus: u32 = undefined;
    
    while (tokens.next()) | token | 
    { 
        bus = try std.fmt.parseInt(u32, token, 10);
   
        const trips: u32 = @divFloor(timeStamp, bus);
        
        const baseTime = trips * bus;
        
        if (baseTime == timeStamp) { bestBus = bus; bestDelay = 0; break; }
        
        const totalTime = baseTime + bus;
        
        const delay: u32 = totalTime - timeStamp;
        
        if (delay < bestDelay) { bestDelay = delay; bestBus = bus; } 
    }

    print("answer: {}\n", .{ bestBus * bestDelay });
}

///////////////////////////////////////////////////////////////////////////////
