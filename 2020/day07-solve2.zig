//! solution for https://adventofcode.com/2020/day/07 part 2

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Bag = struct
{
    active: bool = true,
    color: []const u8 = "",
    parents: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(allocator), // stores the parent color
    children: std.ArrayList(Child) = std.ArrayList(Child).init(allocator), 
    descendants: u32 = 0,
};

const Child = struct
{
    color: []const u8 = "",
    amount: u32 = 0,
};    
    
var allBags: std.ArrayList(Bag) = undefined;


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day07-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var rawLines = std.mem.splitSequence(u8, data, "\n"); 
    
    allBags = try std.ArrayList(Bag).initCapacity(allocator, 600);
    
    while (rawLines.next()) | rawLine | 
    { 
        const line = std.mem.trimRight(u8, rawLine, " ");
        try processLine(line);
    }   
    
    search();
    
    print("answer: {}\n", .{ getBag("shiny-gold").descendants });
}

// process line ///////////////////////////////////////////////////////////////

fn processLine(line: []const u8) !void
{
   // using tokenizeAny: splitAny creates blanks!
   var tokens = std.mem.tokenizeAny(u8, line, " ,."); 
   
    const baseColorA = tokens.next().?;
    const baseColorB = tokens.next().?;
    const parentColor = try std.fmt.allocPrint(allocator, "{s}-{s}", .{ baseColorA, baseColorB });    
    
    var parentBag: *Bag = undefined;
    parentBag = getBag(parentColor);
    
    _= tokens.next(); // bags
    _= tokens.next(); // contain
    
    while (true)
    {
        const token = tokens.next(); 
        
        if (token == null) { break; }
        
        if (std.mem.eql(u8, token.?, "no")) { break; }
        
        const amount = try std.fmt.parseInt(u32, token.?, 10);
                
        const colorA = tokens.next().?;
        const colorB = tokens.next().?;

        _ = tokens.next(); // bags
        
        const childColor = try std.fmt.allocPrint(allocator, "{s}-{s}", .{ colorA, colorB });
        
        putChildInParentBag(parentBag, childColor, amount);
        
        var childBag: *Bag = undefined;
        childBag = getBag(childColor);
        
        putParentInChildBag(childBag, parentColor);
    }
}

fn putChildInParentBag(parentBag: *Bag, childColor: []const u8, amount: u32) void
{
    const child = Child{ .color = childColor, .amount = amount };
    
    parentBag.children.append(child) catch @panic("error in putChildInParentBag");
}

fn putParentInChildBag(childBag: *Bag, parentColor: []const u8) void
{    
    childBag.parents.append(parentColor) catch @panic("error in putParentInChildBag");
}

// search /////////////////////////////////////////////////////////////////////

fn search() void
{
    while (searchOnce()) { }
}

fn searchOnce() bool
{
    for (allBags.items) | *bag |
    {
        if (! bag.active) { continue; }
            
        if (bag.children.items.len != 0) { continue; }
        
        if (std.mem.eql(u8, bag.color, "shiny-gold")) { return false; }

        bag.active = false;
        
        const newDescendants: u32 = bag.descendants + 1; // '1' is for the bag itself
        
        for (bag.parents.items) | parentColor | 
        {
            removeChild(parentColor, bag.color, newDescendants);
        }
        
        return true;
   }   
   return false;
}

fn removeChild(parentColor: []const u8, childColor: []const u8, newDescendants: u32) void
{
    var parent = getBag(parentColor);
        
    var index: u32 = 0;
    
    while (true) 
    {
        const child = parent.children.items[index];
        
        if (! std.mem.eql(u8, child.color, childColor)) { index += 1; continue; }
        
        parent.descendants += child.amount * newDescendants;
        
        break;
    }
    _ = parent.children.swapRemove(index);
}

// helper /////////////////////////////////////////////////////////////////////

fn getBag(color: []const u8) *Bag
{
    const index: ?usize = getIndexOfBag(color);
    
    if (index != null) { return &allBags.items[index.?]; }
    
    const bag: Bag = Bag{ .color = color };
    
    allBags.append(bag) catch @panic("error in getBag");
  
    return getBag(color);
}

fn getIndexOfBag(color: []const u8) ?usize
{
    for (allBags.items, 0..) | bag, index |
    {
        if (std.mem.eql(u8, bag.color, color)) { return index; }
    }
    return null;
}

fn printBag(bag: *Bag) void
{
    print("\nbag color: {s}\n", .{ bag.color });
    for (bag.parents.items) | color | { print("  parent: {s}\n", .{ color }); }
    for (bag.children.items) | child | { print("  child: {s}  {d}\n", .{ child.color, child.amount }); }
    print("\n", .{}); 
}

