//! solution for https://adventofcode.com/2020/day/11 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var map: std.ArrayList([]u8) = undefined;

var memory: []u8 = undefined;

var width: usize = undefined;
var height: usize = undefined;


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day11-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var rawLines = std.mem.splitSequence(u8, data, "\n"); 
    
    map = try std.ArrayList([]u8).initCapacity(allocator, 100);
    
    while (rawLines.next()) | rawLine | 
    { 
        const line = std.mem.trimRight(u8, rawLine, " ");

        const mapLine = createMapLine(line);
        
        try map.append(mapLine);
    }
        
    width = map.items[0].len;
    height = map.items.len;
    
    memory = mapToString();    
   
    while (true)
    {
        updateOnce();

        const mem = mapToString();
        
        if (std.mem.eql(u8, mem, memory)) { break; }
        
        memory = mem;
    }

    print("answer: {}\n", .{ countSeats() });
}

fn createMapLine(source: []const u8) []u8
{
    var temp = std.ArrayList(u8).init(allocator);

    for (source) | char | 
    { 
        temp.append(char) catch @panic("error in createMapLine");
    }
    return temp.items;
}

///////////////////////////////////////////////////////////////////////////////

fn updateOnce() void
{ 
    for (0..height) | row |
    {    
        for (0..width) | col |
        {
            const index = row * width + col;
            
            if (memory[index] == '.') { continue; } // not a seat
                        
            const neighbors = countNeighbors(row, col);
            
            if (memory[index] == 'L') // empty
            {
                if (neighbors == 0) { map.items[row][col] = '#'; }
            }
            else // occupied
            {
                if (neighbors > 4) { map.items[row][col] = 'L'; }
            }
        }
    }
}

fn countNeighbors(_row: usize, _col: usize) i32
{
    const row: i32 = @intCast(_row);
    const col: i32 = @intCast(_col);
    
    var count: i32 = 0;

    count += countNeighbor(row, col, -1, -1);
    count += countNeighbor(row, col, -1,  0);
    count += countNeighbor(row, col, -1,  1);

    count += countNeighbor(row, col, 0, -1);
 // count += countNeighbor(row, col, 0,  0); // center
    count += countNeighbor(row, col, 0,  1);

    count += countNeighbor(row, col,  1, -1);
    count += countNeighbor(row, col,  1,  0);
    count += countNeighbor(row, col,  1,  1);
    
    return count;
}

fn countNeighbor(_row: i32, _col: i32, deltaRow: i32, deltaCol: i32) i32
{   
    var row: i32 = _row;
    var col: i32 = _col;
    
    while (true) 
    {
        row += deltaRow;
        col += deltaCol;
        
        if (row < 0) { return 0; }
        if (col < 0) { return 0; }

        if (row >= height) { return 0; }
        if (col >= width)  { return 0; }
        
        const index = @abs(row) * width + @abs(col);
        
        if (memory[index] == 'L') { return 0; }
        if (memory[index] == '#') { return 1; }
    }
    unreachable;
}

///////////////////////////////////////////////////////////////////////////////

fn mapToString() []u8
{
    var str: []u8 = "";
    
    for (map.items) | item |
    {
        str = std.fmt.allocPrint(allocator, "{s}{s}", .{ str, item }) catch @panic("error in mapToString");
    }

    return str;
}

fn countSeats() u32
{
    var count: u32 = 0;
    
    for (memory) | char | 
    { 
        if (char == '#') { count += 1; } 
    }
    return count;
}

///////////////////////////////////////////////////////////////////////////////

fn showMemory() void
{
    print("\n", .{});
        
    for (0..height) | row |
    {
        for (0..width) | col |
        {
            const index = row * width + col;
            
            print("{c}", .{ memory[index] }); 
        }
        print("\n", .{});
    }
}

