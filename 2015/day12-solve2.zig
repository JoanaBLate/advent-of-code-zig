//! solution for https://adventofcode.com/2015/day/12 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();


pub fn main() !void
{
    defer arena.deinit();

    const rawData: []const u8 = @embedFile("day12-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var tokens = try tokenize(data);
    
    tokens = try simplify(tokens);
    
 // for (tokens.items) |token| { print("{s} ", .{ token }); }
    
    while (true)
    {
        if (tokens.items.len == 3) { break; }
        
        tokens = try consolidateNumbers(tokens);
        
     // for (tokens.items) |token| { print("{s} ", .{ token }); }
        
        if (tokens.items.len == 3) { break; }
       
        tokens = try consolidateSimpleStructures(tokens);
        
     // for (tokens.items) |token| { print("{s} ", .{ token }); }
    }
    
    print("answer: {s}\n", .{ tokens.items[1] });
}

///////////////////////////////////////////////////////////////////////////////

fn tokenize(data: []const u8) !std.ArrayList([]u8)
{
    var tokens = try std.ArrayList([]u8).initCapacity(allocator, 15000);

    var insideString = false;
    
    var token = try stringToSlice("");
            
    for (data) |c|
    {
        if (insideString)
        { 
            token = try appendChar(token, c);
            
            if (c != '"') { continue; }
            
            try tokens.append(token); token = ""; insideString = false; continue;
        }

        if (c == '-') { token = try stringToSlice("-"); continue; }
        
        if (c >= '0'  and  c <= '9') { token = try appendChar(token, c); continue; }
        
        if (token.len != 0) { try tokens.append(token); token = ""; }
                
        if (c == '"') { token = try stringToSlice("\""); insideString = true; continue; }
        
        try tokens.append(try charToSlice(c));
    }
    
    return tokens;
}

fn simplify(source: std.ArrayList([]u8)) !std.ArrayList([]u8)
{
    const oldTokens = source.items;
    
    var newTokens = try std.ArrayList([]u8).initCapacity(allocator, 5000);
    
    var index: usize = 0;
    while (index < oldTokens.len) : (index += 1)
    {
        const token = oldTokens[index];
        
        if (token[0] == ',') { continue; }
        
        if (token[0] == '{') { try newTokens.append(token); continue; }
        if (token[0] == '}') { try newTokens.append(token); continue; }
        if (token[0] == '[') { try newTokens.append(token); continue; }
        if (token[0] == ']') { try newTokens.append(token); continue; }
        
        if (token[0] == '"') 
        { 
            const token2 = oldTokens[index + 1];
            if (token2[0] != ':') { continue; } // string inside list
            
            index += 1; // ':'
            
            const token3 = oldTokens[index + 1];
            if (token3[0] != '"') { continue; }
            
            // field value is string
            index += 1; 
            if (std.mem.eql(u8, "\"red\"", token3)) { try newTokens.append(token3); }
            continue;
        }
        
        try newTokens.append(token);  // number
    }

    source.deinit();
    return newTokens;
}

fn consolidateNumbers(source: std.ArrayList([]u8)) !std.ArrayList([]u8)
{
    const oldTokens = source.items;
    
    var newTokens = try std.ArrayList([]u8).initCapacity(allocator, 5000);
        
    var index: usize = 0;
    while (index < oldTokens.len) : (index += 1)
    {
        const token = oldTokens[index];
        
        if (token[0] == '{') { try newTokens.append(token); continue; }
        if (token[0] == '}') { try newTokens.append(token); continue; }
        if (token[0] == '[') { try newTokens.append(token); continue; }
        if (token[0] == ']') { try newTokens.append(token); continue; }
        
        // now, only red mark or number
        
        const lastNewToken = newTokens.getLast();
        
        const gotRedMark = lastNewToken[0] == '"';
        
        if (gotRedMark) { continue; } // skips current token (number or red mark)
        
        if (token[0] == '"')  // red mark
        { 
            if (isNumber(lastNewToken)) { _ = newTokens.pop(); }
            try newTokens.append(token); 
            continue; 
        }
        
        // now, only number
        
        if (! isNumber(lastNewToken)) { try newTokens.append(token); continue; }
        
        // merging numbers
        
        const value1 = try std.fmt.parseInt(i32, lastNewToken, 10);
        const value2 = try std.fmt.parseInt(i32, token, 10);
        const newToken = try std.fmt.allocPrint(allocator, "{d}", .{ value1 + value2 });
        
        _ = newTokens.pop();        
        try newTokens.append(newToken);
    }

    source.deinit();
    return newTokens;
}

fn consolidateSimpleStructures(source: std.ArrayList([]u8)) !std.ArrayList([]u8)
{
    const oldTokens = source.items;
    const maxIndex: usize = source.items.len - 1;
    
    var newTokens = try std.ArrayList([]u8).initCapacity(allocator, 5000);
        
    var index: usize = 0;
    while (true)
    {
        if (index > maxIndex) { break; }
        
        const a = oldTokens[index];

        if (index == maxIndex) { try newTokens.append(a); break; }
        
        const b = oldTokens[index + 1];
        
        if (a[0] == '{' and b[0] == '}') { index += 2; continue; } // {}
        if (a[0] == '[' and b[0] == ']') { index += 2; continue; } // []
        
        if (index == maxIndex - 1)
        {
            try newTokens.append(a);
            try newTokens.append(b);
            index += 2;
            continue;
        }
        
        const c = oldTokens[index + 2];
               
        if (a[0] == '{') 
        { 
            if (c[0] != '}') { try newTokens.append(a); index += 1; continue; } // not simple structure
            index += 3; // simple structure
            if (b[0] == '"') { continue; } // {"red"}
            try newTokens.append(b); // {number}
            continue;
        }
               
        if (a[0] == '[') 
        { 
            if (c[0] != ']') { try newTokens.append(a); index += 1; continue; } // not simple structure
            index += 3; // simple structure
            if (b[0] == '"') { continue; } // {"red"}
            try newTokens.append(b); // {number}
            continue;
        }

        try newTokens.append(a); 
        index += 1;
    }

    source.deinit();
    return newTokens;
}

// helper /////////////////////////////////////////////////////////////////////

fn charToSlice(char: u8) ![]u8 // expecting literal char
{
    return try std.fmt.allocPrint(allocator, "{c}", .{ char });
}

fn stringToSlice(string: []const u8) ![]u8 // expecting literal string
{
    return try std.fmt.allocPrint(allocator, "{s}", .{ string });
}

fn appendChar(slice: []u8, char: u8) ![]u8
{
    return try std.fmt.allocPrint(allocator, "{s}{c}", .{ slice, char });
}

fn appendSlice(slice1: []u8, slice2: []u8) ![]u8
{
    return try std.fmt.allocPrint(allocator, "{s}{s}", .{ slice1, slice2 });
}

fn isNumber(token: []u8) bool
{
    if (token[0] == '-') { return true; }        
    if (token[0] <  '0') { return false; }
    if (token[0] >  '9') { return false; }
    return true;
}

