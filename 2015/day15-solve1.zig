//! solution for https://adventofcode.com/2015/day/15 part 1

//
// expecting 4 ingredients!
//

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Ingredient = struct 
{
    name: []const u8,
    capacity: i32,
    durability: i32,
    flavor: i32,
    texture: i32,
    calories: i32,
};

var ingredients: [4]Ingredient = undefined;

var bestScore: i32 = 0;

pub fn main() !void
{
    defer arena.deinit();

    const rawData: []const u8 = @embedFile("day15-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");

    var index: u8 = 0;
    while (lines.next()) | line | { try processInputLine(line, index); index += 1; }
    
    tryRandomFormulas();
    
    print("answer: {}\n", .{ bestScore });
}

fn processInputLine(line: []const u8, index: u8) !void
{
    var tokens = std.mem.splitAny(u8, line, " ");

    var name = tokens.next().?;
    name = name[0..name.len];
    
    _ = tokens.next(); // capacity
    
    var capacityStr = tokens.next().?;
    capacityStr = capacityStr[0..capacityStr.len - 1];
    const capacity = try std.fmt.parseInt(i32, capacityStr, 10);
    
    _ = tokens.next(); // durability
    
    var durabilityStr = tokens.next().?;
    durabilityStr = durabilityStr[0..durabilityStr.len - 1];
    const durability = try std.fmt.parseInt(i32, durabilityStr, 10);
    
    _ = tokens.next(); // flavor
    
    var flavorStr = tokens.next().?;
    flavorStr = flavorStr[0..flavorStr.len - 1];
    const flavor = try std.fmt.parseInt(i32, flavorStr, 10);
    
    _ = tokens.next(); // texture
    
    var textureStr = tokens.next().?;
    textureStr = textureStr[0..textureStr.len - 1];
    const texture = try std.fmt.parseInt(i32, textureStr, 10);
    
    _ = tokens.next(); // calories
    
    const caloriesStr = tokens.next().?;
    const calories = try std.fmt.parseInt(i32, caloriesStr, 10);
    
    ingredients[index] = Ingredient{ 
        .name = name,
        .capacity = capacity,
        .durability = durability,
        .flavor = flavor,
        .texture = texture,
        .calories = calories    
    };
}  

fn tryRandomFormulas() void
{
    var countA: i32 = 0;

    while (countA < 101) : (countA += 1)
    { 
        tryRandomFormulas2(countA);
    }
}

fn tryRandomFormulas2(countA: i32) void
{
    var countB: i32 = 0;

    while (countB < 101) : (countB += 1)
    { 
        tryRandomFormulas3(countA, countB);
    }
}

fn tryRandomFormulas3(countA: i32, countB: i32) void
{
    var countC: i32 = 0;

    while (countC < 101) : (countC += 1)
    { 
        tryRandomFormulas4(countA, countB, countC);
    }
}

fn tryRandomFormulas4(countA: i32, countB: i32, countC: i32) void
{
    var countD: i32 = 0;

    while (countD < 101) : (countD += 1)
    { 
        tryRandomFormulas5(countA, countB, countC, countD);
    }
}

fn tryRandomFormulas5(countA: i32, countB: i32, countC: i32, countD: i32) void
{
    if (countA + countB + countC + countD != 100) { return; }
    
    const a = ingredients[0];
    const b = ingredients[1];
    const c = ingredients[2];
    const d = ingredients[3];

    var capacity = (countA * a.capacity) + (countB * b.capacity) + (countC * c.capacity) + (countD * d.capacity);
    if (capacity < 0) { capacity = 0; }

    var durability = (countA * a.durability) + (countB * b.durability) + (countC * c.durability) + (countD * d.durability);
    if (durability < 0) { durability = 0; }
    
    var flavor = (countA * a.flavor) + (countB * b.flavor) + (countC * c.flavor) + (countD * d.flavor);
    if (flavor < 0) { flavor = 0; }

    var texture = (countA * a.texture) + (countB * b.texture) + (countC * c.texture) + (countD * d.texture);
    if (texture < 0) { texture = 0; }

    const score = capacity * durability * flavor * texture;
    
    if (score > bestScore) { bestScore = score; }
}

