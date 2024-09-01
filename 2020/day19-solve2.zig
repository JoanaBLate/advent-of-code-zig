// solution for https://adventofcode.com/2020/day/19 part 2

// *** THIS SOLUTION MAY NOT WORK FOR YOUR SPECIFIC INPUT *** //

// *** Expecting 129 nodes (from 0 to 128) *** //
// *** Expecting 2 simple base nodes ("a" and "b") *** //

const std = @import("std");

const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Node = struct
{
    index: usize = 0,
    done: bool = false,
    rule: []const u8 = "",
};

const numberOfNodes: u32 = 129;

var allNodes: [numberOfNodes]Node = undefined;

var literals11 = std.ArrayList([]const u8).init(allocator);
var literals42 = std.ArrayList([]const u8).init(allocator);


pub fn main() !void
{
    defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day19-input.txt");

    var parts = std.mem.tokenizeSequence(u8, rawData, "\n\n");
        
    const part1 = parts.next().?;
    
    const part2 = parts.next().?;
    
    var lines = std.mem.tokenizeAny(u8, part1, "\n\r");
    
    while (lines.next()) | line | { try processRuleFromInput(line); }
    
    // manually adjusting to the puzzle:
    
    allNodes[8].rule  = "[42] [42][8]";
    allNodes[11].rule = "[42][31] [42][11][31]";
                  
    _= try   replaceWithLiterals();
    _= try   replaceWithLiterals();
    _= try   replaceWithLiterals();
    _= try   replaceWithLiterals();
    _= try   replaceWithLiterals();
    _= try   replaceWithLiterals();
    _= try   replaceWithLiterals();
    
 // for (allNodes) | node | { if ( !node.done) { display(node); } }

 // AT THIS POINT:
 // 1) all literal parts are **8 chars** long
 // 2) the only nodes that still have links are
      
 // #0:  [8][11]
 // #8:  [42] [42][8]
 // #11: [42]aabbbbba [42]aabbaaba [42]aabaaaba ... [42][11]baababbb [42][11]baaabbbb [42][11]baaaabbb ...
       
    try fillListOfLiteralsFrom(&literals11, allNodes[11].rule);
    try fillListOfLiteralsFrom(&literals42, allNodes[42].rule);

    var count: u32 = 0;
    
    var messages = std.mem.tokenizeAny(u8, part2, "\n\r ");
    
    while (messages.next()) | message |
    {        
        if (messageIsOk(message)) { count += 1; }
    }
    
    print("answer: {}\n", .{ count });
}

fn processRuleFromInput(line: []const u8) !void
{
    var parts = std.mem.tokenizeAny(u8, line, ":");
   
    const key = parts.next().?;    
    const data = parts.next().?;
    
    const index = try std.fmt.parseInt(usize, key, 10);

    var node = &allNodes[index];
    
    node.index = index;
    
    var branches = std.mem.tokenizeAny(u8, data, "|");
   
    while (branches.next()) | branch |
    {
        var tokens = std.mem.tokenizeAny(u8, branch, "\" ");
        
        const token = tokens.next().?;

        if (token[0] == 'a') { node.rule = token; return; }
        if (token[0] == 'b') { node.rule = token; return; }
        
        var link = try std.fmt.allocPrint(allocator, "[{s}]", .{ token });
        
        if (tokens.next()) | token2 |
        {
            link = try std.fmt.allocPrint(allocator, "[{s}][{s}]", .{ token, token2 });
        }
        
        if (node.rule.len == 0) { node.rule = link; continue; }
        
        node.rule = try std.fmt.allocPrint(allocator, "{s} {s}", .{ node.rule, link });       
    }
}

fn fillListOfLiteralsFrom(list: *std.ArrayList([]const u8), source: []const u8) !void
{
    var tokens = std.mem.tokenizeAny(u8, source, " [42][11]"); // or just " 124[]"
    
    while (tokens.next()) | token | { try list.append(token); }
}

// replace ////////////////////////////////////////////////////////////////////

fn replaceWithLiterals() !bool
{
    var changed = false;
    
    for (&allNodes) | *node | 
    { 
        if (node.done) { continue; }
        
        if (std.mem.indexOfScalar(u8, node.rule, '[') != null) { continue;}
        
        const link = try std.fmt.allocPrint(allocator, "[{}]", .{ node.index });
        
        const thisChanged = try replaceWithLiteral(link, node.rule);
        
        if (thisChanged) { changed = true; } else { node.done = true; } 
    }
    return changed;
}
        
fn replaceWithLiteral(link: []const u8, wholeReplacement: []const u8) !bool
{    
    var changed = false;
    
    for (&allNodes) | *node | 
    { 
        if (node.done) { continue; }
        
        if (std.mem.indexOf(u8, node.rule, link) == null) { continue; }
        
        try replaceWithLiteralThis(node, link, wholeReplacement);

        changed = true;
    }
    return changed;
}

fn replaceWithLiteralThis(node: *Node, link: []const u8, wholeReplacement: []const u8) !void // expected to have change
{
    var newSubrules = std.ArrayList([]const u8).init(allocator);
    
    var oldSubrules = std.mem.tokenizeAny(u8, node.rule, " ");
    
    while (oldSubrules.next()) | subrule |
    {
        if (std.mem.indexOf(u8, subrule, link) == null) 
        { 
            try newSubrules.append(subrule); 
        }
        else
        {
            try createNewSubrules(&newSubrules, subrule, link, wholeReplacement);
        }
    }
    
    removeDuplicates(&newSubrules);
    
    var newRule: []const u8 = "";
    
    for (newSubrules.items) | subrule |
    {
        newRule = try std.fmt.allocPrint(allocator, "{s} {s}", .{ newRule, subrule });
    }
    
    node.rule = newRule[1..];  
}       

fn createNewSubrules(currentSubrules: *std.ArrayList([]const u8), oldSubrule: []const u8, 
  
                     link: []const u8, wholeReplacement: []const u8) !void
{
    const linkStart = std.mem.indexOf(u8, oldSubrule, link).?;
    
    const linkEnd = linkStart + link.len - 1;
    
    const head = oldSubrule[0..linkStart];
    
    const tail = oldSubrule[linkEnd+1..];

    var replacements = std.mem.tokenizeAny(u8, wholeReplacement, " ");
    
    while (replacements.next()) | replacement | 
    {    
        const newSubrule = try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ head, replacement, tail });
        
        try currentSubrules.append(newSubrule);
    }   
}

// checking a message /////////////////////////////////////////////////////////

// #0:  [8][11]
// #8:  [42] [42][8]
// #11: [42]aabbbbba [42]aabbaaba [42]aabaaaba ... [42][11]baababbb [42][11]baaabbbb [42][11]baaaabbb ...

// notes:
// minimum size for rule #8 is 8 chars (1 segment)
// minimum size for rule #11 is 16 chars (2 segments)
// there is no maximum size for a part
// left part only accepts #42 segments
// right part must start with a #42 segment
       
fn messageIsOk(message: []const u8) bool
{
    if (message.len % 8 != 0) { return false; }

    const numberOfSegments = message.len / 8;
    
    for (1..numberOfSegments-1) | numberOfLeftSegments |
    {
        const edge = numberOfLeftSegments * 8;
        
        const leftPart = message[0..edge];
        const rightPart = message[edge..];

        if (! leftPartIsOk(leftPart)) { continue; }
        
        if (rightPartIsOk(rightPart)) { return true; }
    }
    return false;
}
    
fn leftPartIsOk(message: []const u8) bool
{
    var start: usize = 0;
    
    while (start < message.len) : (start += 8)
    {
        const token = message[start..start+8];
        
        if (! listContains(literals42, token)) { return false; }
    }   
    return true;
}

fn rightPartIsOk(message: []const u8) bool 
{
    if (message.len < 16) { return false; }
    
    const head = message[0..8];

    if (! listContains(literals42, head)) { return false; }
        
    // after removing the starting literal42,
    // there are two valid ways:
    // 1) a literal11 and nothing more
    // 2) another link11 + a literal11
    // in both cases the message ends with literal11
    
    const tailIndex = message.len - 8;
    
    const tail = message[tailIndex..];
    
    if (! listContains(literals11, tail)) { return false; }
    
    // first way -- literal42(removed)+literal11(removed)
    if (message.len == 16) { return true; }

    // second way -- literal42(removed)+link11+literal11(removed)
    const body = message[8..tailIndex];

    return rightPartIsOk(body);
}

// helper /////////////////////////////////////////////////////////////////////

fn removeDuplicates(list: *std.ArrayList([]const u8)) void
{
    var highIndex: usize = list.items.len;
     
    while (highIndex > 0) 
    {
        highIndex -= 1;
        
        const highItem = list.items[highIndex];
        
        for (0..highIndex) | lowIndex |
        {
            const lowItem = list.items[lowIndex];
            
            if (std.mem.eql(u8, highItem, lowItem)) 
            {
                _ = list.orderedRemove(highIndex); // in practice, doesn't happen
                break;
            }
        }
    }
} 

fn listContains(list: std.ArrayList([]const u8), token: []const u8) bool
{
    for (list.items) | item |
    {
        if (std.mem.eql(u8, item, token)) { return true; }
    }
    return false;
}

fn display(node: Node) void
{
    print("#{}:  {s}", .{ node.index, node.rule });
    
    if (node.done) { print("   DONE", .{}); }

    print("\n", .{});
}

