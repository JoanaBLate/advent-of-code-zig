// solution for https://adventofcode.com/2020/day/18 part 1

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
    while (tokens.items.len > 1)
    {
        eliminateParentheses(tokens);

        try addOrMultiply(tokens);
    }

    return try parseInt(tokens.items[0]);
}

fn parseInt(str: []const u8) !usize
{
    return try std.fmt.parseInt(usize, str, 10);
}

fn eliminateParentheses(tokens: *std.ArrayList([]const u8)) void
{
    for (0..tokens.items.len) | index |
    {
        if (index + 2 >= tokens.items.len) { return; }
        
        if (tokens.items[index][0] != '(') { continue; }
        
        if (tokens.items[index + 2][0] != ')') { continue; }
    
        _ = tokens.orderedRemove(index + 2);        
        _ = tokens.orderedRemove(index);
        
        return; // !!!       
    }
}

fn addOrMultiply(tokens: *std.ArrayList([]const u8)) !void
{
    for (0..tokens.items.len) | index |
    {
        const operation = tokens.items[index][0];
        
        if (operation != '+'  and  operation != '*') { continue; }
        
        const aString = tokens.items[index - 1];
        const bString = tokens.items[index + 1];
        
        if (aString[0] == ')') { continue; }
        if (bString[0] == '(') { continue; }
    
        const a = try parseInt(aString);
        const b = try parseInt(bString);
        
        const result: usize = if (operation == '+')  a + b  else  a * b;
        
        tokens.items[index] = try std.fmt.allocPrint(allocator, "{}", .{ result });
        
        _ = tokens.orderedRemove(index + 1);        
        _ = tokens.orderedRemove(index - 1);
        
        return; // !!!
    }
}

