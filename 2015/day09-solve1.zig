//! solution for https://adventofcode.com/2015/day/9 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();
     
var cities: std.ArrayList([] const u8) = undefined;

var distances = std.StringHashMap(u32).init(allocator);

var shortestDistance: u32 = 9_999_999;


pub fn main() !void
{
    defer arena.deinit();
    
    cities = try std.ArrayList([] const u8).initCapacity(allocator, 15);

    const rawData: []const u8 = @embedFile("day09-input.txt");

    const data = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");
    
    while (lines.next()) |line| { try processDataLine(line); }
    
    for (cities.items) |city| 
    { 
        var journey = try std.ArrayList([] const u8).initCapacity(allocator, 10);
        try journey.append(city);
        try keepTravel(journey); 
    }
        
    print("answer: {d}\n", .{ shortestDistance });
}

fn processDataLine(line: []const u8) !void
{    
    var tokens = std.mem.tokenize(u8, line, " ");

    const city1 = tokens.next().?;    
    if (! cityExists(city1)) { try cities.append(city1); }

    _ = tokens.next(); // 'to'
    
    const city2 = tokens.next().?;    
    if (! cityExists(city2)) { try cities.append(city2); }

    _ = tokens.next(); // '='
    
    const value = tokens.next().?;
    
    const distance = try std.fmt.parseInt(u32, value, 10);
    
    const name1 = try getTravelName(city1, city2);
    try distances.put(name1, distance);    
    
    const name2 = try getTravelName(city2, city1);
    try distances.put(name2, distance);    
}

fn cityExists(city: []const u8) bool
{
    for (cities.items) |current|
    {
        if (std.mem.eql(u8, city, current)) { return true; }
    }
    return false;
}

// journey ////////////////////////////////////////////////////////////////////

fn keepTravel(journey: std.ArrayList([] const u8)) !void
{
    // this is a recursive function (calls itself)
    // we don't need a struture for storing data of the journeys,
    // because this function (and its many clones) store them as arguments
    
    if (journey.items.len == cities.items.len) { try tryAsWinner(journey); return; }

    for (cities.items) |city| {
            
        if (journeyIncludesCity(journey, city)) { continue; } // cloning avoids one journey messing with other
        
        var newJourney = try journey.clone();
        
        try newJourney.append(city);
        
        try keepTravel(newJourney);
    }
}

fn journeyIncludesCity(journey: std.ArrayList([] const u8), city: []const u8) bool
{
    for (journey.items) |current|
    {
        if (std.mem.eql(u8, city, current)) { return true; }
    }
    return false;
}

fn tryAsWinner(journey: std.ArrayList([] const u8)) !void
{
    var distance: u32 = 0; 
    
    var index: usize = 0;
    while (true)
    {    
        index += 1;
        if (index == journey.items.len) { break; }
      
        const city1 = journey.items[index - 1];
        const city2 = journey.items[index];
        
        const travel = try getTravelName(city1, city2);
        
        distance += distances.get(travel).?;
    }
    
    if (distance < shortestDistance) { shortestDistance = distance; }
}

// helper /////////////////////////////////////////////////////////////////////

fn getTravelName(city1: []const u8, city2: []const u8) ![]const u8
{
    return try std.mem.concat(allocator, u8, &[_][]const u8{ city1, "~", city2 });
}

