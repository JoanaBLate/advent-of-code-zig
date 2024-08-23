//! solution for https://adventofcode.com/2020/day/04 part 2

const std = @import("std");

const print = std.debug.print;

// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
// const allocator = arena.allocator();


pub fn main() !void
{
 // defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day04-input.txt");
    
    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lineGroups = std.mem.splitSequence(u8, data, "\n\n");
    
    var count: u32 = 0;
    
    while (lineGroups.next()) | lineGroup | 
    { 
        if (isValidPassport(lineGroup)) { count += 1; }
    }
        
    print("answer: {}\n", .{ count });
}

fn isValidPassport(lineGroup: []const u8) bool
{
    var count: u32 = 0;
    
    var tokens = std.mem.splitAny(u8, lineGroup, " \n");
        
    while (tokens.next()) | token |
    {
        const fieldName: []const u8 = token[0..3];
        const fieldValue: []const u8 = token[4..];
        
        if (std.mem.eql(u8, fieldName, "cid")) { continue; }
        
        count += 1; 
        
        if (std.mem.eql(u8, fieldName, "byr")) 
        { 
            if (! numberOk(fieldValue, 1920, 2002)) { return false; }
            continue;
        }
        
        if (std.mem.eql(u8, fieldName, "iyr")) 
        { 
            if (! numberOk(fieldValue, 2010, 2020)) { return false; }
            continue;
        }
        
        if (std.mem.eql(u8, fieldName, "eyr")) 
        { 
            if (! numberOk(fieldValue, 2020, 2030)) { return false; }
            continue;
        }
        
        if (std.mem.eql(u8, fieldName, "hgt")) 
        { 
            if (fieldValue.len < 3) { return false; }
            
            const len = fieldValue.len;
            const head: []const u8 = fieldValue[0..len-2];
            const end:  []const u8 = fieldValue[len-2..];
            
            if (std.mem.eql(u8, end, "cm"))
            {
                if (! numberOk(head, 150, 193)) { return false; }
            }  
            else if (std.mem.eql(u8, end, "in"))
            {
                if (! numberOk(head, 59, 76)) { return false; }
            }  
            else { return false; }
            
            continue;
        }
            
        if (std.mem.eql(u8, fieldName, "hcl")) 
        { 
            if (fieldValue.len != 7) { return false; } 

            if (fieldValue[0] != '#') { return false; }

            for (fieldValue[1..]) | char |
            {
                if (char >= '0'  and  char <= '9') { continue; }
                if (char >= 'a'  and  char <= 'f') { continue; }
                return false;
            }
            continue;
        }
            
        if (std.mem.eql(u8, fieldName, "ecl")) 
        { 
            var colors = std.mem.splitAny(u8, "amb,blu,brn,gry,grn,hzl,oth", ",");
            
            var match = false;
            while(colors.next()) | color |
            {
                if (std.mem.eql(u8, fieldValue, color)) { match = true; break; }
            }
            if (! match) { return false; }
            continue;
        }
        
        if (std.mem.eql(u8, fieldName, "pid")) 
        { 
            if (fieldValue.len != 9) { return false; } 

            for (fieldValue) | char |
            {
                if (char < '0' or char > '9') { return false; }
                continue;
            }            
            continue;
        }
    }

    return count == 7;
}

fn numberOk(str: []const u8, min: u32, max: u32) bool
{
    const number: u32 = std.fmt.parseInt(u32, str, 10) catch { return false; };
    
    if (number < min) { return false; }
    if (number > max) { return false; }
    
    return true;
}

