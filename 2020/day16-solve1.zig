//! solution for https://adventofcode.com/2020/day/16 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Range = struct
{
    rangeALow:  u32,
    rangeAHigh: u32,
    rangeBLow:  u32,
    rangeBHigh: u32,
};

var fieldNames = std.ArrayList([]const u8).init(allocator);

var fieldRanges = std.ArrayList(Range).init(allocator);

var errors: u32 = 0;


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day16-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var parts = std.mem.tokenizeSequence(u8, data, "\n\n");
    
    const part1 = parts.next().?;    
    
    const part2 = parts.next().?; // my ticket
    _= part2;
    const part3 = parts.next().?;
    
    processModel(part1);
    processNearbyTickets(part3);

    print("answer: {}\n", .{ errors });
}

fn processModel(src: []const u8) void
{
    var lines = std.mem.tokenizeAny(u8, src, "\n\r");
    
    while (lines.next()) | line | { processField(line); }
}

fn processField(line: []const u8) void
{
    var segments = std.mem.tokenizeAny(u8, line, ":");
    
    const name = segments.next().?;
    
    fieldNames.append(name) catch @panic("error in processField");

    const ranges = segments.next().?;
    
    var tokens = std.mem.tokenizeAny(u8, ranges, " ,or-");
    
    const range = Range{ 
        .rangeALow  = std.fmt.parseInt(u32, tokens.next().?, 10) catch @panic("error in processField"),
        .rangeAHigh = std.fmt.parseInt(u32, tokens.next().?, 10) catch @panic("error in processField"),
        .rangeBLow  = std.fmt.parseInt(u32, tokens.next().?, 10) catch @panic("error in processField"),
        .rangeBHigh = std.fmt.parseInt(u32, tokens.next().?, 10) catch @panic("error in processField"),
    };
    
    fieldRanges.append(range) catch @panic("error in processField");
}

fn processNearbyTickets(src: []const u8) void
{
    var lines = std.mem.tokenizeAny(u8, src, "\n\r");
    
    _ = lines.next(); // 'nearby tickets:'
    
    while (lines.next()) | line |
    {
        processNearbyTicket(line);
    }
}
  
fn processNearbyTicket(line: []const u8) void
{  
    var tokens = std.mem.tokenizeAny(u8, line, ", ");
    
    while (tokens.next()) | token |
    {
        const number: u32 = std.fmt.parseInt(u32, token, 10) catch @panic("error in processNearbyTicket");
        
        if (! numberFitsModel(number)) { errors += number; }
    }
}

fn numberFitsModel(number: u32) bool
{
    for (fieldRanges.items) | range |
    {
        if (number >= range.rangeALow  and  number <= range.rangeAHigh) { return true; }
        if (number >= range.rangeBLow  and  number <= range.rangeBHigh) { return true; }
    }
    return false;
}

