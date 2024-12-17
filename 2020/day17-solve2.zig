// solution for https://adventofcode.com/2020/day/17 part 2

//  *** EXPECTING A 8X8 GRID AS INPUT ***  //

// Each turn the grid increases 2 ghost dimensions, 2 layers, 2 rows and 2 cols.
// After 6 turns there will be 13 ghost dimsensions, 13 layers of one grid with 20 rows and 20 cols. 

const std = @import("std");

const print = std.debug.print;

// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
// const allocator = arena.allocator();

const Cube = struct
{
    lit: bool = false,
    neighbors: u32 = 0, // count of lit neighbors
};

const maxGhost: usize = 12; // 13 layers
const maxLayer: usize = 12; // 13 layers
const maxRow: usize = 19;   // 20 rows
const maxCol: usize = 19;   // 20 cols

var universe: [13][13][20][20]Cube = undefined; // ghost/layer/row/col/cube


pub fn main() void
{
 // defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day17-input.txt");

    var lines = std.mem.tokenizeAny(u8, rawData, "\n\r ");
    
    fillTheUniverse();
    
    const ghost: usize = 6; // center ghost
    
    const layer: usize = 6; // center layer
    
    var row: usize = 6; // adjusted row
    
    while (lines.next()) | line |
    {
        var col: usize = 6; // adjusted col
        
        for (line) | char |
        {
            var cube = &universe[ghost][layer][row][col];
            
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
    for (0..maxGhost+1) | ghost |
    {
        for (0..maxLayer+1) | layer |
        {
            for (0..maxRow+1) | row |
            {
                for (0..maxCol+1) | col |
                {
                    universe[ghost][layer][row][col] = Cube{};
                }
            }
        }
    }
}

fn countActiveCubes() usize
{
    var count: usize = 0;

    for (0..maxGhost+1) | ghost |
    {
        for (0..maxLayer+1) | layer |
        {
            for (0..maxRow+1) | row |
            {
                for (0..maxCol+1) | col |
                {
                    const cube = universe[ghost][layer][row][col];
                    if (cube.lit) { count += 1; }
                }
            }
        }
    }
    return count;
}
    
///////////////////////////////////////////////////////////////////////////////

fn runCycle() void
{
    resetNeighbors(); // more efficient because
    markNeighbors();  // non lit cubes do nothing
    updateCubes();
}

fn resetNeighbors() void
{
    for (0..maxGhost+1) | ghost |
    {
        for (0..maxLayer+1) | layer |
        {
            for (0..maxRow+1) | row |
            {
                for (0..maxCol+1) | col |
                {
                    var cube = &universe[ghost][layer][row][col];
                    cube.neighbors = 0;
                }
            }
        }
    }
}

fn markNeighbors() void
{
    for (0..maxGhost+1) | ghost |
    {
        for (0..maxLayer+1) | layer |
        {
            for (0..maxRow+1) | row |
            {
                for (0..maxCol+1) | col |
                {
                    markNeighborsFrom(ghost, layer, row, col);
                }
            }
        }
    }
}

fn updateCubes() void
{
    for (0..maxGhost+1) | ghost |
    {
        for (0..maxLayer+1) | layer |
        {
            for (0..maxRow+1) | row |
            {
                for (0..maxCol+1) | col |
                {
                    var cube = &universe[ghost][layer][row][col];
                    
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
}

///////////////////////////////////////////////////////////////////////////////

fn markNeighborsFrom(ghost: usize, layer: usize, row: usize, col: usize) void
{    
    var centerCub = &universe[ghost][layer][row][col];
    
    if (! centerCub.lit) { return; } // time saver

    markNeighbor_A(ghost, layer, row, col); 
    
    if (ghost != 0)
    {
        markNeighbor_A(ghost - 1, layer, row, col);    
    }
    
    if (ghost < maxGhost)
    {
        markNeighbor_A(ghost + 1, layer, row, col);    
    }
    
    centerCub.neighbors -= 1; // fixing self mark
}

fn markNeighbor_A(ghost: usize, layer: usize, row: usize, col: usize) void
{    
    markNeighbor_B(ghost, layer, row, col); 
    
    if (layer != 0)
    {
        markNeighbor_B(ghost, layer - 1, row, col);    
    }
    
    if (layer < maxLayer)
    {
        markNeighbor_B(ghost, layer + 1, row, col);    
    }
}

fn markNeighbor_B(ghost: usize, layer: usize, row: usize, col: usize) void
{    
    markNeighbor_C(ghost, layer, row, col); 
    
    if (row != 0)
    {
        markNeighbor_C(ghost, layer, row - 1, col);    
    }
    
    if (row < maxRow)
    {
        markNeighbor_C(ghost, layer, row + 1, col);    
    }
}

fn markNeighbor_C(ghost: usize, layer: usize, row: usize, col: usize) void
{    
    markNeighbor_D(ghost, layer, row, col); 
    
    if (col != 0)
    {
        markNeighbor_D(ghost, layer, row, col - 1);    
    }
    
    if (col < maxCol)
    {
        markNeighbor_D(ghost, layer, row, col + 1);    
    }    
}

fn markNeighbor_D(ghost: usize, layer: usize, row: usize, col: usize) void
{
    var cub = &universe[ghost][layer][row][col];
    
    cub.neighbors += 1; 
}

