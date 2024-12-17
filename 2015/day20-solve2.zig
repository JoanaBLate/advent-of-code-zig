//! solution for https://adventofcode.com/2015/day/20 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day20-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    const totalPresents: usize = try std.fmt.parseInt(usize, data, 10);
        
    // We need an array to represent the houses. It cannot be infinite. 
    // Each house receives, at least, 11 presents:

    const _maxHouses: usize = totalPresents / 11; // granted to have enough houses

    // Santa counts the houses starting from one (not zero). In order to easy the code we 
    // will do the same, despising the zero position, and adding one more item as compensation:

    const maxHouses: usize = _maxHouses + 1;

    var houses = try std.ArrayList(usize).initCapacity(allocator, maxHouses);
    
    for (0..maxHouses+1) | _ | { try houses.append(0); } // filling
    
    for (1..maxHouses+1) | elf | // taking elf by elf
    {
        var visitsPerElf: u32 = 0;
        // taking only the houses that match the elf step
        var houseIndex: usize = elf;
        while (houseIndex <= maxHouses) : (houseIndex += elf) 
        { 
            houses.items[houseIndex] += 11 * elf; 
            visitsPerElf += 1;
            if (visitsPerElf == 50) { break; }
        }
    }
    
    for (1..maxHouses+1) | houseIndex |
    {
        if (houses.items[houseIndex] >= totalPresents) { print("answer: {}\n", .{ houseIndex }); break; }
    }
}

