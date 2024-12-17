// solution for https://adventofcode.com/2020/day/20 part 1

// for this solution we only care about the borders;
    
//    for efficiency, the border values are translated into 
//    binary numbers, and then converted to decimal numbers
//    
//    actually, we only need to tell the corner tiles!!!
//
//    --
//    
//    corner tiles have 2 neighbors (there are only 4 corner tiles)
//    
//    border (not corner) tiles have 3 neighbors
//    
//    middle tiles have 4 neighbors
//    
//    --
//    
//    for this *SPECIFIC* puzzle input, for all tiles: any border
//    compatible tile is a true neighbor (not just an eventual match)


const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const DIM: usize = 10;   // *** MAY NOT WORK FOR YOUR SPECIFIC INPUT *** //

const Tile = struct
{
    id: []const u8 = undefined,
    
    image: [DIM][DIM]u8 = undefined,
    
    borders: [8]usize = undefined, // top, bottom, left, right + reversed (top, bottom, left, right)
        
    numberOfMatches: usize = 0, 
           
    done: bool = false,
};

var allTiles = std.ArrayList(Tile).init(allocator);

var allBorderCodes = [1]usize{ 0 } ** std.math.pow(usize, 2, DIM);


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day20-input.txt");

    var rawSegments = std.mem.tokenizeSequence(u8, rawData, "\n\n");
           
    while (rawSegments.next()) | rawSegment | 
    {
        const segment = std.mem.trimRight(u8, rawSegment, "\n\r ");
        
        try createTileFromInput(segment); 
    }
    
 // for (allBorderCodes) | value | { print("{} ", .{ value }); }
 // print("\n\n", .{});
    
    countMatches();
    
 // for (allTiles.items) | tile | { display(tile); }
        
    print("answer: {}\n", .{ search() });
}

fn createTileFromInput(segment: []const u8) !void
{
    var tile = Tile{};
        
    var lines = std.mem.tokenizeAny(u8, segment, "\n\r");
    
    var temp = std.mem.tokenizeAny(u8, lines.next().?, "Tile :");
    
    tile.id = temp.next().?;
    
    var leftColumn: [DIM]u8 = undefined;
    var rightColumn: [DIM]u8 = undefined;
    
    for (0..DIM) | row |
    {
        const line = lines.next().?;

        leftColumn[row] = line[0];
        rightColumn[row] = line[DIM - 1];

        for (0..DIM) | col |
        {
            tile.image[row][col] = line[col];
        }
    }
    
    tile.borders[0] = encode(tile.image[0]); // top
    tile.borders[1] = encode(tile.image[DIM - 1]); // bottom    
    tile.borders[2] = encode(leftColumn); // left  
    tile.borders[3] = encode(rightColumn); // right
    
    tile.borders[4] = reverseEncode(tile.image[0]); // top
    tile.borders[5] = reverseEncode(tile.image[DIM - 1]); // bottom    
    tile.borders[6] = reverseEncode(leftColumn); // left  
    tile.borders[7] = reverseEncode(rightColumn); // right
                    
    try allTiles.append(tile);
}

fn encode(array: [DIM]u8) usize // also registers at allBorderCodes
{
    var binary = [1]u8{ 66 } ** DIM;
    
    for (0..DIM) | index |
    {
        binary[index] = if (array[index] == '#')  '1'  else  '0';
    }
    
    const code = std.fmt.parseInt(usize, &binary, 2) catch @panic("error in encode");
    
    allBorderCodes[code] += 1;
   
    return code;
}

fn reverseEncode(array: [DIM]u8) usize // also registers at allBorderCodes
{
    var binary = [1]u8{ 66 } ** DIM;
    
    for (0..DIM) | index |
    {
        const counterIndex: usize = DIM - 1 - index;
        
        binary[index] = if (array[counterIndex] == '#')  '1'  else  '0';
    }
    
    const code = std.fmt.parseInt(usize, &binary, 2) catch @panic("error in encode");
    
    allBorderCodes[code] += 1;
   
    return code;
}

fn countMatches() void
{    
    for (allTiles.items) | *tile | 
    {
        tile.numberOfMatches = countMatchesFor(tile.*);
    }
}

fn countMatchesFor(tile: Tile) usize
{
    var count: usize = 0;

    for (tile.borders) | border |
    {
        if (allBorderCodes[border] > 1) { count += 1; }
    }
    return count / 2;
}

// search /////////////////////////////////////////////////////////////////////

fn search() usize
{
    var result: usize = 1;
    
    for (allTiles.items) | tile |
    {
        if (tile.numberOfMatches != 2) { continue; }
        
        const factor = std.fmt.parseInt(usize, tile.id, 10) catch @panic("error in search");
        result *= factor;
    }
    return result;
}

///////////////////////////////////////////////////////////////////////////////

fn display(tile: Tile) void
{
    print("\nid:{s}   matches: {}\n", .{ tile.id, tile.numberOfMatches });
    print("borders: {any}\n", .{ tile.borders });
}

