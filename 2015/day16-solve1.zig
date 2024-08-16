//! solution for https://adventofcode.com/2015/day/16 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var profile = std.StringHashMap(u32).init(allocator);

var winner: usize = undefined;


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day16-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");

    try fillProfile();
    
    var lines = std.mem.splitAny(u8, data, "\n");

    while (lines.next()) | line | { try processInputLine(line); }

    print("answer: Sue {d}\n", .{ winner });
}

fn fillProfile() !void
{
    try profile.put("cats", 7);
    try profile.put("cars", 2);
    try profile.put("trees", 3);
    try profile.put("akitas", 0);
    try profile.put("vizslas", 0);
    try profile.put("children", 3);
    try profile.put("goldfish", 5);
    try profile.put("samoyeds", 2);
    try profile.put("perfumes", 1);
    try profile.put("pomeranians", 3);
}

fn processInputLine(line: []const u8) !void
{
    var tokens = std.mem.splitAny(u8, line, " ");    
    
    _ = tokens.next(); // Sue

    const rawName = tokens.next().?; 
       
    for (0..3) | turn |
    {
        const label = processLabel(tokens.next().?);
        const rawValue = tokens.next().?;

        const value = try processValue(rawValue, turn);
        
        const profileValue = profile.get(label).?;
        
        if (value != profileValue) { return; }
    }
    
    winner = try processValue(rawName, 1);
}

fn processLabel(token: []const u8) []const u8
{
    return token[0..token.len-1]; // extracts comma
}

fn processValue(token: []const u8, turn: usize) !usize
{
    const end: usize = if (turn == 2) token.len else token.len-1;  // extracts comma or not
    
    return try std.fmt.parseInt(usize, token[0..end], 10);
}

