//! solution for https://adventofcode.com/2015/day/18 part 2

const std = @import("std");

const print = std.debug.print;

// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
// const allocator = arena.allocator();

var lightGrid: [100][100]bool = undefined;


pub fn main() !void
{
 // defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day18-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");

    for (0..100) | index |
    {
        lightGrid[index] = [1]bool{ false } ** 100;
    }
    
    var rowIndex: u32 = 0;
    while (lines.next()) | line | 
    { 
        var row = &lightGrid[rowIndex];
        
        var charIndex: u32 = 0;
        
        for (line) | char |
        {
            if (char == '#') { row[charIndex] = true; }
            charIndex += 1;
        }
        
        rowIndex += 1;
    }
    
    for (0..100) | _ | { updateLightGrid(); }

    print("answer: {d}\n", .{ countLightsOn() });
}

fn updateLightGrid() void
{
    const oldGrid = lightGrid;
    
    for (0..100) | row |
    {
        for (0..100) | col |
        {
            updateLight(&oldGrid, row, col);
        }
    }
}

fn updateLight(oldGrid: *const[100][100]bool, row_: usize, col_: usize) void
{    
    const row: i32 = @intCast(row_);
    const col: i32 = @intCast(col_);
    
    if (row == 0  or  row == 99)
    {
        if (col == 0  or  col == 99) { return; }
    }
    
    var neighborsOn: i8 = 0;
    
    neighborsOn += isLightOn(oldGrid, row - 1, col - 1);
    neighborsOn += isLightOn(oldGrid, row - 1, col    );
    neighborsOn += isLightOn(oldGrid, row - 1, col + 1);
    
    
    neighborsOn += isLightOn(oldGrid, row, col - 1);
//  neighborsOn += isLightOn(oldGrid, row, col    ); // current light
    neighborsOn += isLightOn(oldGrid, row, col + 1);
    
    neighborsOn += isLightOn(oldGrid, row + 1, col - 1);
    neighborsOn += isLightOn(oldGrid, row + 1, col    );
    neighborsOn += isLightOn(oldGrid, row + 1, col + 1);
    
    const currentIsOn = oldGrid[row_][col_];

    if (currentIsOn)
    {
        lightGrid[row_][col_] = (neighborsOn == 2  or  neighborsOn == 3);    
    }
    else
    {
        lightGrid[row_][col_] = (neighborsOn == 3);  
    }
}

fn isLightOn(oldGrid: *const[100][100]bool, row: i32, col: i32) i8
{    
    if (row <   0) { return 0; }
    if (col <   0) { return 0; }
    if (row >  99) { return 0; }
    if (col >  99) { return 0; }
    
    const lightOn = oldGrid[@abs(row)][@abs(col)];
    
    return if (lightOn)  1  else  0;
}

fn countLightsOn() u32
{
    var count: u32 = 0;

    for (0..100) | row |
    {
        for (0..100) | col |
        {
            if (lightGrid[row][col]) { count += 1; }
        }
    }
    
    return count;
}

