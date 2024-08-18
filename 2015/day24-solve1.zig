//! solution for https://adventofcode.com/2015/day/24 part 1

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

// for this puzzle, a combination like [ 1, 3, 2 ] is the same as [ 1, 2, 3 ]

// if we don't abort wrong and/or redundant branches as soon as possible,
// we will end up with a HUGE number of combinations

const Node = struct
{
    useds: []bool = undefined,
    indexOfLastUsed: usize = undefined,
    sum: u32 = 0,
    packages: u32 = 0, // the count in the main compartment
};

var weights: []u32 = undefined;

var target: u32 = undefined; // target weight for each compartment

var maxNumberOfPackages: u32 = undefined; // it is 1/3 of the total number of packages

var lowestNumberOfPackages: u32 = 99;
var lowestQuantumEntanglement: usize = 999_999_999;


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day24-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    try fillWeights(data);
    
    const len: u32 = @intCast(weights.len);
    maxNumberOfPackages =  len / 3; // integer division
    
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
    target = total / 3;
    
    weights = list.items;
}

fn sortBiggerFirst() void
{
    while (sortBiggerFirstOnce()) { }
}

fn sortBiggerFirstOnce() bool
{
    for (0..weights.len-1) | index |
    {
        if (weights[index] >= weights[index + 1]) { continue; }
        
        const temp = weights[index];
        weights[index] = weights[index + 1];
        weights[index + 1] = temp;
        return true;
    }
    return false;
}

///////////////////////////////////////////////////////////////////////////////

fn search() !void
{
    for (0..weights.len) | index | 
    {
        var node = try createNode();
        
        node.useds[index] = true;
        node.indexOfLastUsed = index;
        node.sum = weights[index];
        node.packages = 1;
     
        try searchFirstCompartment(&node);
    }
}

fn searchFirstCompartment(node: *Node) !void
{
    const start: usize = node.indexOfLastUsed + 1; // this grants [2,1,3] will never happen
    if (start >= weights.len) { return; }
    
    for (start..weights.len) | index | 
    {
        const sum: u32 = node.sum + weights[index];
        
        if (sum > target) { continue; }
        
        const packages = node.packages + 1;
        
        if (packages > maxNumberOfPackages) { return; } // next loop would have too many packages too
        
        var newNode = try createNode();

        for (0..weights.len) | n | { newNode.useds[n] = node.useds[n]; }        
        newNode.useds[index] = true;
        newNode.indexOfLastUsed = index;
        newNode.sum = sum;
        newNode.packages = packages;
        
        if (sum < target) { try searchFirstCompartment(&newNode); continue; }
        
        // newSum == target
        try evaluateNode(&newNode);
    }
}

///////////////////////////////////////////////////////////////////////////////
        
fn evaluateNode(node: *Node) !void
{
    const qe = calcQuantumEntanglement(node);

    if (node.packages > lowestNumberOfPackages) { return; }
        
    if (node.packages == lowestNumberOfPackages  and  qe >= lowestQuantumEntanglement) { return; }
    
    if (! otherCompartmentsWillBeOk(node)) { return; }

    //
    
    if (node.packages < lowestNumberOfPackages) 
    { 
        lowestNumberOfPackages = node.packages;
        lowestQuantumEntanglement = qe;
        return; 
    }

    if (qe < lowestQuantumEntanglement) { lowestQuantumEntanglement = qe; }
}

///////////////////////////////////////////////////////////////////////////////

// just need to check the second one! 
// (the third one must be ok when the second is ok)

fn otherCompartmentsWillBeOk(node: *Node) bool 
{
    for (0..weights.len) | index | 
    {
        if (node.useds[index]) { continue; }
        
        const weight = weights[index];

        if (secondSearch(weight, weight)) { return true; }
    }
    return false;
}

fn secondSearch(sum: u32, lowestWeight: u32) bool
{
    for (weights) | weight | 
    {
        if (weight >= lowestWeight) { continue; }
        
        const newSum = sum + weight;
        
        if (newSum > target)  { continue; }
        
        if (newSum == target) { return true; }
        
        return secondSearch(newSum, weight);
    }
    
    return false;
}
      
// helper /////////////////////////////////////////////////////////////////////

fn createNode() !Node
{
    var list = try std.ArrayList(bool).initCapacity(allocator, 30);
    for (0..weights.len) | _ | { try list.append(false); }
    
    return Node{ .useds = list.items };
}

fn calcQuantumEntanglement(node: *Node) usize
{
   var qe: usize = 1;

    for (0..weights.len) | index |
    {
         if (node.useds[index]) { qe *= weights[index]; }
    }
    return qe;
}

fn displayNode(node: *Node) void
{
    print("sum: {d} ", .{ node.sum });
    
    for (0..weights.len) | index |
    {
        if (! node.useds[index]) { print("    ", .{}); continue; }
    
        print("  {d}", .{ weights[index] });
    }
    print("\n", .{}); 
}

