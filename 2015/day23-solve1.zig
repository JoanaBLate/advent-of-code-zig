//! solution for https://adventofcode.com/2015/day/23 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var instructions: std.ArrayList([]const u8) = undefined;

var regA: i32 = 0;
var regB: i32 = 0;
var pointer: i32 = 0;

var shallStop = false;


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day23-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");
    
    instructions = try std.ArrayList([]const u8).initCapacity(allocator, 50);
    
    while (lines.next()) | line | { try instructions.append(line); }
    
    while (! shallStop) { try executeNextInstruction(); }

    print("answer: {}\n", .{ regB });
}

fn executeNextInstruction() !void
{
    if (pointer >= instructions.items.len) { shallStop = true; return; }
    
    const line = instructions.items[@abs(pointer)];
    
    if (std.mem.eql(u8, line, "inc a")) { regA += 1; pointer += 1; return; }
    
    if (std.mem.eql(u8, line, "inc b")) { regB += 1; pointer += 1; return; }

    if (std.mem.eql(u8, line, "tpl a")) { regA *= 3; pointer += 1; return; }

    if (std.mem.eql(u8, line, "tpl b")) { regB *= 3; pointer += 1; return; }

    if (std.mem.eql(u8, line, "hlf a")) { regA = @divFloor(regA, 2); pointer += 1; return; }

    if (std.mem.eql(u8, line, "hlf b")) { regB = @divFloor(regB, 2); pointer += 1; return; }
        
    const cmd = line[0..3];

    var rest = line[4..];

    if (std.mem.eql(u8, cmd, "jmp")) 
    { 
        pointer += try std.fmt.parseInt(i32, rest, 10); 
        return; 
    }
    
    const regValue = if (rest[0] == 'a') regA else regB;
    
    rest = rest[3..];
    
    const offset = try std.fmt.parseInt(i32, rest, 10);    
    
    if (std.mem.eql(u8, cmd, "jie"))
    { 
        pointer += if (@rem(regValue, 2) == 0) offset else 1;
        return;
    }
    
    if (std.mem.eql(u8, cmd, "jio")) 
    {     
        pointer += if (regValue == 1) offset else 1;
        return;
    }
        
    shallStop = true;
}


