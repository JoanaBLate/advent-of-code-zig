// solution for https://adventofcode.com/2020/day/17 part 1

//  *** EXPECTING A 8X8 GRID AS INPUT ***  //

// Each turn the grid increases 2 layers, 2 rows and 2 cols.
// After 6 turns there will be 13 layers of one grid with 20 rows and 20 cols. 

const std = @import("std");

const print = std.debug.print;

// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
// const allocator = arena.allocator();

const Cube = struct
{
    lit: bool = false,
    neighbors: u32 = 0, // count of neighbors
};

const maxLayer: usize = 12; // 13 layers
const maxRow: usize = 19;   // 20 rows
const maxCol: usize = 19;   // 20 cols

var universe: [13][20][20]Cube = undefined; // layer/row/col/cube


pub fn main() void
{
 // defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day17-input.txt");

    var lines = std.mem.tokenizeAny(u8, rawData, "\n\r ");
    
    fillTheUniverse();
    
    const layer: usize = 6; // center layer
    
    var row: usize = 6; // adjusted row
    
    while (lines.next()) | line |
    {
        var col: usize = 6; // adjusted col
        
        for (line) | char |
        {
            var cube = &universe[layer][row][col];
            
            if (char == '#') { cube.lit = true; }
        
            col += 1;
        }
        
        row += 1;
    }
    
    for (0..6) | _ | { runCycle(); }
    
    print("answer: {}\n", .{ countActiveCubes() });
}

fn fillTheUniverse() void
{
    for (0..maxLayer+1) | layer |
    {
        for (0..maxRow+1) | row |
        {
            for (0..maxCol+1) | col |
            {
                universe[layer][row][col] = Cube{};
            }
        }
    }
}

fn countActiveCubes() usize
{
    var count: usize = 0;

    for (0..maxLayer+1) | layer |
    {
        for (0..maxRow+1) | row |
        {
            for (0..maxCol+1) | col |
            {
                const cube = universe[layer][row][col];
                if (cube.lit) { count += 1; }
            }
        }
    }
    return count;
}
    
///////////////////////////////////////////////////////////////////////////////

fn runCycle() void
{
    countNeighbors();
    updateCubes();
}

fn countNeighbors() void
{
    for (0..maxLayer+1) | layer |
    {
        for (0..maxRow+1) | row |
        {
            for (0..maxCol+1) | col |
            {
                countNeighborsFor(layer, row, col);
            }
        }
    }
}

fn updateCubes() void
{
    for (0..maxLayer+1) | layer |
    {
        for (0..maxRow+1) | row |
        {
            for (0..maxCol+1) | col |
            {
                var cube = &universe[layer][row][col];
                
                if (cube.lit)
                {
                    if (cube.neighbors == 2  or cube.neighbors == 3) { continue; }
                    
                    cube.lit = false;
                }
                else 
                {
                    if (cube.neighbors == 3) { cube.lit = true; }        
                }
            }
        }
    }
}

///////////////////////////////////////////////////////////////////////////////

fn countNeighborsFor(layer_: usize, row_: usize, col_: usize) void
{    
    const layer: i32 = @intCast(layer_);

    const row: i32 = @intCast(row_);
    const col: i32 = @intCast(col_);
    
    var count: u32 = 0;

    count += countNeighborsForOnLayer(layer - 1, row, col);
    count += countNeighborsForOnLayer(layer    , row, col);
    count += countNeighborsForOnLayer(layer + 1, row, col);
    
    var centerCub = &universe[@abs(layer)][@abs(row)][@abs(col)];

    if (centerCub.lit) { count -= 1; }

    centerCub.neighbors = count;
}
  
fn countNeighborsForOnLayer(layer: i32, row: i32, col: i32) u32
{
    if (layer < 0)  { return 0; }
    if (layer > maxLayer) { return 0; }
    
    var count: u32 = 0;
    
    count += countThisNeighbor(layer, row - 1, col - 1);
    count += countThisNeighbor(layer, row - 1, col    );
    count += countThisNeighbor(layer, row - 1, col + 1);
    
    count += countThisNeighbor(layer, row    , col - 1);
    count += countThisNeighbor(layer, row    , col    );
    count += countThisNeighbor(layer, row    , col + 1);
    
    count += countThisNeighbor(layer, row + 1, col - 1);
    count += countThisNeighbor(layer, row + 1, col    );
    count += countThisNeighbor(layer, row + 1, col + 1);
    
    return count;
}

fn countThisNeighbor(layer: i32, row: i32, col: i32) u32
{
    if (row < 0)  { return 0; }
    if (col < 0)  { return 0; }
    
    if (row > maxRow) { return 0; }
    if (col > maxCol) { return 0; }

    const cube = universe[@abs(layer)][@abs(row)][@abs(col)];
    
    return if (cube.lit) 1 else 0;
}

