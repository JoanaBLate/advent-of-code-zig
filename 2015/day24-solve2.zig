//! solution for https://adventofcode.com/2015/day/24 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

// for this puzzle, a combination like [ 1, 3, 2 ] is the same as [ 1, 2, 3 ]

// if we don't abort wrong and/or redundant branches as soon as possible,
// we will end up with a HUGE number of combinations

var WEIGHTS: []u32 = undefined;

var target: u32 = undefined; // target weight for each compartment

var maxNumberOfPackages: u32 = undefined; // it is 1/4 of the total number of packages

var lowestNumberOfPackages: u32 = 99;
var lowestQuantumEntanglement: usize = 999_999_999;


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day24-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    try fillWeights(data);
    
    const len: u32 = @intCast(WEIGHTS.len);
    maxNumberOfPackages =  len / 4; // integer division
    
    sortBiggerFirst();
    
    try search();
    
    print("answer: {}\n", .{ lowestQuantumEntanglement });
}

///////////////////////////////////////////////////////////////////////////////

fn fillWeights(data: []const u8) !void
{
    var lines = std.mem.splitAny(u8, data, "\n");
    
    var list = try std.ArrayList(u32).initCapacity(allocator, 30);
    
    var total: u32 = 0;
    
    while (lines.next()) | line | 
    { 
        const weight = try std.fmt.parseInt(u32, line, 10);
        total += weight;
        try list.append(weight); 
    }
    
    target = total / 4;
    
    WEIGHTS = list.items;
}

fn sortBiggerFirst() void
{
    while (sortBiggerFirstOnce()) { }
}

fn sortBiggerFirstOnce() bool
{
    for (0..WEIGHTS.len-1) | index |
    {
        if (WEIGHTS[index] >= WEIGHTS[index + 1]) { continue; }
        
        const temp = WEIGHTS[index];
        WEIGHTS[index] = WEIGHTS[index + 1];
        WEIGHTS[index + 1] = temp;
        return true;
    }
    return false;
}

///////////////////////////////////////////////////////////////////////////////

fn search() !void
{
    for (WEIGHTS) | weight | 
    {  
        var packages = try std.ArrayList(u32).initCapacity(allocator, 30);
        try packages.append(weight); 
        try searchCenterCompartment(packages, weight);
    }
}

fn searchCenterCompartment(packages: std.ArrayList(u32), sum: u32) !void
{   
    const lowest = packages.getLast();

    for (WEIGHTS) | weight |  
    {        
        if (weight >= lowest) { continue; } // this grants [2,1,3] will never happen
        
        const newSum: u32 = sum + weight;
        
        if (newSum > target) { continue; }
        
        if (packages.items.len + 1 > maxNumberOfPackages) { return; } // next loop would have too many packages too
        
        var newPackages = try std.ArrayList(u32).initCapacity(allocator, 30);
        for (packages.items) | item | { try newPackages.append(item); }
        try newPackages.append(weight);
        
        if (newSum < target) { try searchCenterCompartment(newPackages, newSum); continue; }
               
        // newSum == target
        try evaluateCandidate(newPackages);
    }
}

///////////////////////////////////////////////////////////////////////////////
        
fn evaluateCandidate(packages: std.ArrayList(u32)) !void
{
    const qe = calcQuantumEntanglement(packages.items);

    if (packages.items.len > lowestNumberOfPackages) { return; }
        
    if (packages.items.len == lowestNumberOfPackages  and  qe >= lowestQuantumEntanglement) { return; }
    
    if (! try otherCompartmentsOk(packages.items)) { return; }
    //
    
    if (packages.items.len < lowestNumberOfPackages) 
    { 
        lowestNumberOfPackages = @intCast(packages.items.len);
        lowestQuantumEntanglement = qe;
        return; 
    }
    // packages.itens.len == lowestNumberOfPackages
    if (qe < lowestQuantumEntanglement) { lowestQuantumEntanglement = qe; }
}

fn calcQuantumEntanglement(weights: []u32) usize
{
    var qe: usize = 1;
    for (weights) | weight | { qe *= weight; }
    return qe;
}

///////////////////////////////////////////////////////////////////////////////

fn otherCompartmentsOk(taken: []u32) !bool
{
    for (WEIGHTS) | weight | 
    {  
        var packages = try std.ArrayList(u32).initCapacity(allocator, 30);
        
        if (std.mem.indexOfScalar(u32, taken, weight) != null) { continue; }
        
        try packages.append(weight); 

        if (try otherCompartmentsOk2(taken, packages, weight))
        {
            return true;
        }
    }
    return false;
}

// second compartment
fn otherCompartmentsOk2(taken: []u32, packages: std.ArrayList(u32), sum: u32) !bool
{
    const lowest = packages.getLast();

    for (WEIGHTS) | weight |  
    {       
        if (weight >= lowest) { continue; } // this grants [2,1,3] will never happen
        
        if (std.mem.indexOfScalar(u32, taken, weight) != null) { continue; }
        
        const newSum: u32 = sum + weight;
        
        if (newSum > target) { continue; }
        
        if (packages.items.len + 1 > maxNumberOfPackages) { return false; } // next loop would have too many packages too
        
        var newPackages = try std.ArrayList(u32).initCapacity(allocator, 30);
        for (packages.items) | item | { try newPackages.append(item); }
        try newPackages.append(weight);
        
        if (newSum < target) { return try otherCompartmentsOk2(taken, newPackages, newSum); }
               
        // newSum == target
        return try otherCompartmentsOk3(taken, newPackages.items);
    }
    return false;
}

// third compartment 
fn otherCompartmentsOk3(taken: []u32, taken2: []u32) !bool
{        
    for (WEIGHTS) | weight | 
    {  
        var packages = try std.ArrayList(u32).initCapacity(allocator, 30);
        
        if (std.mem.indexOfScalar(u32, taken,  weight) != null) { continue; }
        if (std.mem.indexOfScalar(u32, taken2, weight) != null) { continue; }
        
        try packages.append(weight); 

        if (try otherCompartmentsOk4(taken, taken2, packages, weight))
        {
            return true; // (need not to check the fourth compartment)
        }
    }
    return false;
}

// still the third compartment
fn otherCompartmentsOk4(taken: []u32, taken2: []u32, packages: std.ArrayList(u32), sum: u32) !bool
{
    const lowest = packages.getLast();

    for (WEIGHTS) | weight |  
    {
        if (weight >= lowest) { continue; } // this grants [2,1,3] will never happen
        
        if (std.mem.indexOfScalar(u32, taken,  weight) != null) { continue; }
        if (std.mem.indexOfScalar(u32, taken2, weight) != null) { continue; }
        
        const newSum: u32 = sum + weight;
        
        if (newSum == target) { return true; }
        
        if (newSum > target) { continue; }
        
        // newSum < target
        if (packages.items.len + 1 > maxNumberOfPackages) { return false; } // next loop would have too many packages too
        
        var newPackages = try std.ArrayList(u32).initCapacity(allocator, 30);
        for (packages.items) | item | { try newPackages.append(item); }
        try newPackages.append(weight);
        
        return try otherCompartmentsOk4(taken, taken2, newPackages, newSum);
    }    
    return false;
}

