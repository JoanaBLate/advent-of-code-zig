//! solution for https://adventofcode.com/2015/day/14 part 1

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
};

var reindeers: std.ArrayList(Reindeer) = undefined;

const fullTime:u32 = 2503;

var bestDistance: u32 = 0;


pub fn main() !void
{
    defer arena.deinit();

    const rawData: []const u8 = @embedFile("day14-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    reindeers = try std.ArrayList(Reindeer).initCapacity(allocator, 10);
    
    var lines = std.mem.splitAny(u8, data, "\n");
    
    while (lines.next()) | line | { try processInputLine(line); }
    
    for (reindeers.items) | reindeer | { evaluateReindeer(reindeer); }

    print("{d}\n", .{ bestDistance });
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

fn evaluateReindeer(reindeer: Reindeer) void
{
    const cycleTime: u32 = reindeer.flyTime + reindeer.restTime;

    const doneCycles: u32 = fullTime / cycleTime; // floor division
    
    const remainingTime: u32 = fullTime - (doneCycles * cycleTime);
    
    const remainingFlyTime: u32 = if (remainingTime >= reindeer.flyTime) reindeer.flyTime else remainingTime;
    
    const distance: u32 = (doneCycles * reindeer.flyTime * reindeer.speed) + (remainingFlyTime * reindeer.speed);
    
    if (distance > bestDistance) { bestDistance = distance; }
}

