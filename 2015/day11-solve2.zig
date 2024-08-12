//! solution for https://adventofcode.com/2015/day/11 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();


pub fn main() !void
{
    defer arena.deinit();

    const rawData: []const u8 = @embedFile("day11-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");

    // gives a non constant slice
    const password: []u8 = try std.fmt.allocPrint(allocator, "{s}", .{ data });
    
    updatePassword(password);
    updatePassword(password);
    
    print("answer: {s}\n", .{ password });
}
    
fn updatePassword(password: []u8) void
{  
    while (true) {
    
        increasePassword(password);
        
        if (hasForbiddenLetters(password)) { continue; }
        if (! hasIncreasingTrio(password)) { continue; }
        if (! hasTwoIndependentPairs(password)) { continue; }
        
        break;    
    }
}

fn increasePassword(password: []u8) void
{
    var index: usize = password.len - 1;
    
    while (true)
    {
        if (password[index] < 'z') { password[index] += 1; return; }
        
        password[index] = 'a';
        
        index -= 1;
    }
}

fn hasForbiddenLetters(password: []u8) bool
{

    for (password) |c|
    {
        if (c == 'i') { return true; }
        if (c == 'l') { return true; }
        if (c == 'o') { return true; }
    }
    return false;
}

fn hasIncreasingTrio(password: []u8) bool
{
    for (2..password.len) |index|
    {
        const a = password[index - 2];
        const b = password[index - 1];
        const c = password[index];
        
        if (a > b) { continue; } // must check to avoid: panic: integer overflow
        if (b > c) { continue; } // must check to avoid: panic: integer overflow
        
        if (b - a != 1) { continue; }
        if (c - b != 1) { continue; }
        return true;
    }
    return false;
}

fn hasTwoIndependentPairs(password: []u8) bool
{
    var pairs: usize = 0;
    
    var index: usize = 0;
    while (true) 
    {
        if (index > password.len - 2) { break; }
        
        if (password[index] != password[index + 1]) { index += 1; continue; }
        
        pairs += 1;        
        if (pairs == 2) { return true; }
        
        index += 2; // jumps next character
    }
    return false;
}

