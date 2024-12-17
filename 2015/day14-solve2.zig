//! solution for https://adventofcode.com/2015/day/14 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Reindeer = struct 
{
    name: []const u8,
    speed: u32,
    flyTime: u32,
    restTime: u32,
    distance: u32 = 0,
    points: u32 = 0,
    isFlying: bool = true,
    elapsedTime: u32 = 0,   // elapsed time in current turn
};

var reindeers: std.ArrayList(Reindeer) = undefined;

const maxTime: u32 = 2503;


pub fn main() !void
{
    defer arena.deinit();

    const rawData: []const u8 = @embedFile("day14-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    reindeers = try std.ArrayList(Reindeer).initCapacity(allocator, 10);
    
    var lines = std.mem.splitAny(u8, data, "\n");
    
    while (lines.next()) | line | { try processInputLine(line); }
    
    for (0..maxTime) | _ | { updateByTick(); }
    
    var bestPoints: u32 = 0;
    
    for (reindeers.items) | reindeer | 
    { 
        if (reindeer.points > bestPoints) { bestPoints = reindeer.points; }
    }
    
    print("answer: {}\n", .{ bestPoints });
}

fn processInputLine(line: []const u8) !void
{
    var tokens = std.mem.splitAny(u8, line, " ");
    
    const name = tokens.next().?;
    
    _ = tokens.next(); // can
    _ = tokens.next(); // fly
    
    const speedStr = tokens.next().?;
    
    const speed: u32 = try std.fmt.parseInt(u32, speedStr, 10);

    _ = tokens.next(); // km/s 
    _ = tokens.next(); // for
    
    const flyTimeStr = tokens.next().?;
    
    const flyTime: u32 = try std.fmt.parseInt(u32, flyTimeStr, 10);
    
    _ = tokens.next(); // seconds, 
    _ = tokens.next(); // but 
    _ = tokens.next(); // then
    _ = tokens.next(); // must
    _ = tokens.next(); // rest
    _ = tokens.next(); // for

    const restTimeStr = tokens.next().?;
    
    const restTime: u32 = try std.fmt.parseInt(u32, restTimeStr, 10); 
          
    const reindeer = Reindeer{ .name = name, .speed = speed, .flyTime = flyTime, .restTime = restTime };
        
    try reindeers.append(reindeer);
}

fn updateByTick() void
{
    var bestDistance: u32 = 0;

    for (reindeers.items) | *reindeer | { updateReindeer(reindeer); }
    
    for (reindeers.items) | reindeer | 
    { 
        if (reindeer.distance > bestDistance) { bestDistance = reindeer.distance; }
    }
    
    for (reindeers.items) | *reindeer | 
    { 
        if (reindeer.distance == bestDistance) { reindeer.points += 1; }
    }
}

fn updateReindeer(reindeer: *Reindeer) void
{
    // one second has passed!
    
    reindeer.elapsedTime += 1;
    
    var maxTime_: u32 = reindeer.restTime;
    
    if (reindeer.isFlying) { reindeer.distance += reindeer.speed; maxTime_ = reindeer.flyTime; }
        
    if (reindeer.elapsedTime == maxTime_)
    {
        reindeer.elapsedTime = 0;
        reindeer.isFlying = ! reindeer.isFlying;
    }
}

