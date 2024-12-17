//! solution for https://adventofcode.com/2020/day/15 part 1

//                                                             //
// **NOT** EXPECTING REPEATED NUMBERS IN THE STARTING LIST!!!  //
//                                                             //

const std = @import("std");

const print = std.debug.print;

// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
// const allocator = arena.allocator();

const size: usize = 2020;

var lastSpoken: usize = undefined;

var turn: usize = 0;

var positions = [1]usize{ 0 } ** size; // most recent position // zero means virgin slot (least turn is 1)


pub fn main() !void
{
 // defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day15-input.txt");
    
    var tokens = std.mem.tokenizeAny(u8, rawData, "\n\r, ");
                
    while (tokens.next())  | token |
    {
        turn += 1;
        
        lastSpoken = try std.fmt.parseInt(usize, token, 10);
        
        positions[lastSpoken] = turn;
    }
    
    lastSpoken = 0; // **NOT** EXPECTING REPEATED NUMBERS IN THE STARTING LIST!!!
    turn += 1;
    
    search();

    print("answer: {}\n", .{ lastSpoken });
}

fn search() void
{    
    while (turn < size)
    {
        const oldPosition: usize = positions[lastSpoken];
        
        positions[lastSpoken] = turn;
                
        lastSpoken = if (oldPosition == 0)  0  else  turn - oldPosition;

        turn += 1;
    } 
}

