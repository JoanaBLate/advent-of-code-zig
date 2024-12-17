// solution for https://adventofcode.com/2020/day/18 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day18-input.txt");

    var lines = std.mem.tokenizeAny(u8, rawData, "\n\r");
        
    var result: usize = 0;
    
    while (lines.next()) | line | { result += try processLine(line); }
    
    print("answer: {}\n", .{ result });
}

fn processLine(line: []const u8) !usize
{
    var tokens = std.ArrayList([]const u8).init(allocator);
    
    var pieces = std.mem.tokenizeAny(u8, line, " ");
    
    while (pieces.next()) | piece |
    { 
        if (piece.len == 1) { try tokens.append(piece); continue; }
    
        var token = piece[0..];
        
        while (token.len != 0)
        {
            try tokens.append(token[0..1]); // all input numbers are single digit!
            
            token = token[1..];        
        }
    }    
    return playTheMath(&tokens);
}

fn playTheMath(tokens: *std.ArrayList([]const u8)) !usize
{
    while (tokens.items.len > 1) { try simplifyExpression(tokens); }

    return try parseInt(tokens.items[0]);
}

fn simplifyExpression(tokens: *std.ArrayList([]const u8)) !void
{
    var start: usize = 0;
    
    for (tokens.items, 0..) | token, index |
    {
        if (token[0] == '(') { start = index; continue; }
        if (token[0] != ')') { continue; }
        
        try simplifyCoreExpression(tokens, start + 1, index - 1);
        
        _ = tokens.orderedRemove(start + 2); // ')'   
        _ = tokens.orderedRemove(start);     // '('
        
        return;       
    }
    try simplifyCoreExpression(tokens, 0, tokens.items.len - 1);
}    

fn simplifyCoreExpression(tokens: *std.ArrayList([]const u8), start: usize, end_: usize) !void
{
    // tokens are granted to come without parentheses    
    
    var end: usize = end_;
    
    while (try addTokens(tokens, start, end)) { end -= 2; }
    
    while (try multiplyTokens(tokens, start, end)) { end -= 2; }
}

fn addTokens(tokens: *std.ArrayList([]const u8), start: usize, end: usize) !bool
{
    if (start == end) { return false; }
    
    for (start+1..end) | index |
    {
        if (tokens.items[index][0] != '+') { continue; }
        
        const aString = tokens.items[index - 1];
        const bString = tokens.items[index + 1];
    
        const a = try parseInt(aString);
        const b = try parseInt(bString);
        
        const result: usize = a + b;
        
        tokens.items[index] = try std.fmt.allocPrint(allocator, "{}", .{ result });
        
        _ = tokens.orderedRemove(index + 1);        
        _ = tokens.orderedRemove(index - 1);
        
        return true;
    }
    return false;
}

fn multiplyTokens(tokens: *std.ArrayList([]const u8), start: usize, end: usize) !bool
{    
    if (start == end) { return false; }
    
    for (start+1..end) | index |
    {
        if (tokens.items[index][0] != '*') { continue; }
        
        const aString = tokens.items[index - 1];
        const bString = tokens.items[index + 1];
    
        const a = try parseInt(aString);
        const b = try parseInt(bString);
        
        const result: usize = a * b;
        
        tokens.items[index] = try std.fmt.allocPrint(allocator, "{}", .{ result });
        
        _ = tokens.orderedRemove(index + 1);        
        _ = tokens.orderedRemove(index - 1);
        
        return true;
    }
    return false;
}

// helper /////////////////////////////////////////////////////////////////////

fn parseInt(str: []const u8) !usize
{
    return try std.fmt.parseInt(usize, str, 10);
}

