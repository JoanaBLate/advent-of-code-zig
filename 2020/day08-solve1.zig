//! solution for https://adventofcode.com/2020/day/08 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Kind = enum { acc, jmp, nop };

const Instruction = struct { kind: Kind, number: i32, visited: bool = false };

var instructions: std.ArrayList(Instruction) = undefined;

var pointer: i32 = 0;

var accumulator: i64 = 0;


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day08-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var rawLines = std.mem.splitSequence(u8, data, "\n"); 
    
    instructions = try std.ArrayList(Instruction).initCapacity(allocator, 1000);
    
    while (rawLines.next()) | rawLine | 
    { 
        const line = std.mem.trimRight(u8, rawLine, " ");
        try processLine(line);
    }
    
    runInstructions();
    
    print("answer: {}\n", .{ accumulator });
}

fn processLine(line: []const u8) !void
{
   var tokens = std.mem.tokenizeAny(u8, line, " "); 
   
   const kind: Kind = getKind(tokens.next().?);
   
   const number: i32 = try std.fmt.parseInt(i32, tokens.next().?, 10);
   
   try instructions.append(Instruction{ .kind = kind, .number = number });
}

fn getKind(token: []const u8) Kind
{
    if (std.mem.eql(u8, token, "acc")) { return .acc; }
    if (std.mem.eql(u8, token, "jmp")) { return .jmp; }
    if (std.mem.eql(u8, token, "nop")) { return .nop; }

    unreachable;
}

fn runInstructions() void
{
    while (true)
    {
        var instruc = &instructions.items[@abs(pointer)];
        
        if (instruc.visited) { return; }
        
        instruc.visited = true;
        
        switch (instruc.kind)
        {
            .acc => { accumulator += instruc.number; pointer += 1; },
            .jmp => { pointer += instruc.number; },
            .nop => { pointer += 1; }
        }
    }
}

