//! solution for https://adventofcode.com/2020/day/16 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const AMOUNT: usize = 20; // *** EXPECTING PUZZLE WITH 20 FIELDS!!! *** //

const Name = struct
{
    name: []const u8,

    rangeALow:  usize,
    rangeAHigh: usize,
    rangeBLow:  usize,
    rangeBHigh: usize,

    possibleColumns: std.ArrayList(usize) = std.ArrayList(usize).init(allocator),
    
    done: bool = false, // has finished searching this    
};

var nameObjs: [AMOUNT]Name = undefined;

var myTicket: [AMOUNT]usize = undefined;

var tickets = std.ArrayList([AMOUNT]usize).init(allocator);


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day16-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var parts = std.mem.tokenizeSequence(u8, data, "\n\n");
    
    const part1 = parts.next().?;   
    const part2 = parts.next().?; // my ticket
    const part3 = parts.next().?;
    
    try processNames(part1);
    try processMyTicket(part2);
    try processNearbyTickets(part3);
    
    try fillPossibleColumns();
 
    filterPossibleColumns();
    
    print("answer: {any}\n", .{ calcResult() });
}

///////////////////////////////////////////////////////////////////////////////

fn processNames(src: []const u8) !void
{
    var lines = std.mem.tokenizeAny(u8, src, "\n\r");
    
    var index: usize = 0;
    
    while (lines.next()) | line | { try processName(line, index); index += 1; }
}

fn processName(line: []const u8, index: usize) !void
{
    var segments = std.mem.tokenizeAny(u8, line, ":");
    
    const name = segments.next().?;
    
    const ranges = segments.next().?;
    
    var tokens = std.mem.tokenizeAny(u8, ranges, " ,or-");
    
    var nameObj: Name = undefined; // making the compiler happy ;)
    
    nameObj = Name{ 
        .name = name,
        .rangeALow  = try std.fmt.parseInt(usize, tokens.next().?, 10),
        .rangeAHigh = try std.fmt.parseInt(usize, tokens.next().?, 10),
        .rangeBLow  = try std.fmt.parseInt(usize, tokens.next().?, 10),
        .rangeBHigh = try std.fmt.parseInt(usize, tokens.next().?, 10),
    };
    
    nameObjs[index] = nameObj;
}

///////////////////////////////////////////////////////////////////////////////

fn processMyTicket(src: []const u8) !void
{
    var lines = std.mem.tokenizeAny(u8, src, "\n");
    
    _= lines.next(); // your ticket:

    const line = lines.next().?;
    
    var tokens = std.mem.tokenizeAny(u8, line, ", ");
    
    var index: usize = 0;
    
    while (tokens.next()) | token |
    {
        const number: usize = try std.fmt.parseInt(usize, token, 10);
        
        myTicket[index] = number;
        
        index += 1;
    }
}

///////////////////////////////////////////////////////////////////////////////

fn processNearbyTickets(src: []const u8) !void
{
    var lines = std.mem.tokenizeAny(u8, src, "\n\r");
    
    _ = lines.next(); // nearby tickets:
    
    while (lines.next()) | line | { try processNearbyTicket(line); }
}
  
fn processNearbyTicket(line: []const u8) !void
{
    var numbers: [AMOUNT]usize = undefined;
    
    var index: usize = 0;
    
    var tokens = std.mem.tokenizeAny(u8, line, ", ");
    
    while (tokens.next()) | token |
    {
        const number: usize = try std.fmt.parseInt(usize, token, 10);
        
        numbers[index] = number;
        
        if (! numberFitsModel(number)) { return; }
        
        index += 1;
    }
    
    try tickets.append(numbers);
}

fn numberFitsModel(number: usize) bool
{
    for (0..AMOUNT) | index |
    {
        const nameObj = nameObjs[index];
        
        if (number >= nameObj.rangeALow  and  number <= nameObj.rangeAHigh) { return true; }
        if (number >= nameObj.rangeBLow  and  number <= nameObj.rangeBHigh) { return true; }
    }
    return false;
}

///////////////////////////////////////////////////////////////////////////////

fn fillPossibleColumns() !void
{
    for (0..AMOUNT) | index | { try fillPossibleColumnsFor(index); }
}

fn fillPossibleColumnsFor(nameObjIndex: usize) !void
{
    var nameObj = &nameObjs[nameObjIndex];
        
    for (0..AMOUNT) | columnIndex |
    {
        if (! isPossibleColumn(nameObj, columnIndex)) { continue; }
        
        try nameObj.possibleColumns.append(columnIndex);
    }
}

fn isPossibleColumn(nameObj: *Name, columnIndex: usize) bool
{
    for (tickets.items) | ticket |
    {
        const number: usize = ticket[columnIndex];
        
        if (number < nameObj.rangeALow)  { return false; }
        if (number > nameObj.rangeBHigh) { return false; }
                
        if (number > nameObj.rangeAHigh  and  number < nameObj.rangeBLow) { return false; }
    }
    return true;
}

///////////////////////////////////////////////////////////////////////////////

fn filterPossibleColumns() void
{
    while (true) 
    {
        var nameObj = findNameObjToFilter();
   
        if (nameObj == null) { return; }

        nameObj.?.done = true;
        
        const column = nameObj.?.possibleColumns.items[0];
        
        filterThisColumn(column);
    }
}
   
fn findNameObjToFilter() ?*Name
{  
    for (&nameObjs) | *nameObj |
    {
        if (nameObj.done) { continue; }
       
        if (nameObj.possibleColumns.items.len == 1) { return nameObj; }   
    }
    return null;
}

fn filterThisColumn(column: usize) void
{  
    for (&nameObjs) | *nameObj |
    {
        if (nameObj.done) { continue; }
        
        const index = std.mem.indexOfScalar(usize, nameObj.possibleColumns.items, column); 
        
        if (index == null) { continue; }
        
        _ = nameObj.possibleColumns.swapRemove(index.?);
    }
}

///////////////////////////////////////////////////////////////////////////////

fn calcResult() usize
{
    var result: usize = 1;

    for (nameObjs) | nameObj |
    {
        const name = nameObj.name;
        
        if (name.len < 9) { continue; }
        
        if (! std.mem.eql(u8, "departure", name[0..9])) {  continue; }
        
        const column: usize = nameObj.possibleColumns.items[0];
        
        result *= myTicket[column]; 
    }
    return result;
}

