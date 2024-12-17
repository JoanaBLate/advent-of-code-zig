//! solution for https://adventofcode.com/2015/day/25

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day25-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var tokens = std.mem.tokenizeAny(u8, data, " ");
    
    for (0..15) | _ | { _ = tokens.next(); }
    
    const rowString = tokens.next().?;
    
    _ = tokens.next();
    
    const colString = tokens.next().?;
    
    const targetRow = try parse(rowString);
    const targetCol = try parse(colString);
    
    const linearIndex: usize = calcLinearIndexInDiagonalGrid(targetRow, targetCol);
    
    var code: usize = 20151125; // index 1 row 1  col 1
    
    var n: usize = 1;
    while(n < linearIndex) : (n += 1) { code = calcNextCode(code); }
    
    print("answer: {}\n", .{ code });
}

fn parse(source: []const u8) !usize
{
    const str = source[0..source.len-1];
    
    return std.fmt.parseInt(usize, str, 10);
}

fn calcLinearIndexInDiagonalGrid(targetRow: usize, targetCol: usize) usize
{
    var row: usize = 1;
    var col: usize = 1;

    var index: usize = 0;
    var rowAtDiagonalStart: usize = 0;
    
    while (true) 
    {
        if (row == targetRow  and  col == targetCol) { break; }
 
        index += 1;
        
        if (row == 1) // must start new diagonal
        {
            col = 1;
            rowAtDiagonalStart += 1;
            row = rowAtDiagonalStart;
            continue;
        }       
        else 
        {
            row -= 1;
            col += 1;
        }        
    }
    return index;
}

fn calcNextCode(current: usize) usize
{
    return (252533 * current) % 33554393;
}

