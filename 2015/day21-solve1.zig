//! solution for https://adventofcode.com/2015/day/21 part 1

const std = @import("std");

const print = std.debug.print;

// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
// const allocator = arena.allocator();

const Info = struct 
{
    cost:   i32 = 0,
    damage: i32 = 0,
    armor:  i32 = 0,
};

const Equipment = struct
{
    attack: i32 = 0,
    defense: i32 = 0,
    cost: i32 = 0,
};

var weapons: [5]Info = undefined;
var armors:  [6]Info = undefined;
var rings:   [7]Info = undefined;

var bossHitPoints: i32 = 0;

var bossDamage: i32 = 0;

var bossArmor: i32 = 0;

var lowestCost:i32 = 999999; // lowest cost with victory


pub fn main() !void
{
 // defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day21-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");
    
    const line1 = std.mem.trimRight(u8, lines.next().?, " ");
    const line2 = std.mem.trimRight(u8, lines.next().?, " ");
    const line3 = std.mem.trimRight(u8, lines.next().?, " ");

    var line1Tokens = std.mem.splitAny(u8, line1, " ");
    _ = line1Tokens.next(); // Hit
    _ = line1Tokens.next(); // Points:
    const hitPointsString = line1Tokens.next().?;
    bossHitPoints = try std.fmt.parseInt(i32, hitPointsString, 10);
    
    var line2Tokens = std.mem.splitAny(u8, line2, " ");
    _ = line2Tokens.next(); // Damage:
    const damageString = line2Tokens.next().?; 
    bossDamage = try std.fmt.parseInt(i32, damageString, 10);
    
    var line3Tokens = std.mem.splitAny(u8, line3, " ");
    _ = line3Tokens.next(); // Armor:
    const armorString = line3Tokens.next().?; 
    bossArmor = try std.fmt.parseInt(i32, armorString, 10);
    
    fillWeapons();
    fillArmors();
    fillRings();

    search();

    print("answer: {}\n", .{ lowestCost });
}

fn fillWeapons() void  
{
    // must use one weapon
    weapons[0] = Info{ .cost =  8, .damage = 4, .armor = 0 }; // Dagger    
    weapons[1] = Info{ .cost = 10, .damage = 5, .armor = 0 }; // Shortsword    
    weapons[2] = Info{ .cost = 25, .damage = 6, .armor = 0 }; // Warhammer    
    weapons[3] = Info{ .cost = 40, .damage = 7, .armor = 0 }; // Longsword    
    weapons[4] = Info{ .cost = 74, .damage = 8, .armor = 0 }; // Greataxe    
}

fn fillArmors() void
{
    armors[0] = Info{ .cost =   0, .damage = 0, .armor = 0 }; // (nothing)
    armors[1] = Info{ .cost =  13, .damage = 4, .armor = 1 }; // Leather    
    armors[2] = Info{ .cost =  31, .damage = 5, .armor = 2 }; // Chainmail    
    armors[3] = Info{ .cost =  53, .damage = 6, .armor = 3 }; // Splintmail    
    armors[3] = Info{ .cost =  75, .damage = 7, .armor = 4 }; // Bandedmail    
    armors[5] = Info{ .cost = 102, .damage = 8, .armor = 5 }; // Platemail    
}

fn fillRings() void
{
    rings[0] = Info{ .cost =   0, .damage = 0, .armor = 0 }; // (nothing)
    rings[1] = Info{ .cost =  25, .damage = 1, .armor = 0 }; // Damage +1
    rings[2] = Info{ .cost =  50, .damage = 2, .armor = 0 }; // Damage +2
    rings[3] = Info{ .cost = 100, .damage = 3, .armor = 0 }; // Damage +3
    rings[4] = Info{ .cost =  20, .damage = 0, .armor = 1 }; // Defense +1
    rings[5] = Info{ .cost =  40, .damage = 0, .armor = 2 }; // Defense +2
    rings[6] = Info{ .cost =  80, .damage = 0, .armor = 3 }; // Defense +3
}

fn search() void
{
    for (0..5) | w | // weapon index
    {    
        for (0..6) | a | // armor index
        {
            for (0..7) | r | // ring1 index
            {
                for (0..7) | s | // ring2 index
                {        
                    const costOfVictory = shopAndFight(w, a, r, s);
                    
                    if (costOfVictory == null) { continue; }

                    if (costOfVictory.? < lowestCost) { lowestCost = costOfVictory.?; } 
                }
            }
        }
    }
}

fn shopAndFight(w: usize, a: usize, r: usize, s: usize) ?i32
{  
    if (r == s) { return null; }  // cannot repeat rings
    
    const attack: i32 = weapons[w].damage + rings[r].damage + rings[s].damage;
    const defense: i32 = armors[a].armor + rings[r].armor + rings[s].armor;
    const cost: i32 = weapons[w].cost + armors[a].cost + rings[r].cost + rings[s].cost;
    
    return if (winsFight(attack, defense)) cost else null;
}

fn winsFight(myAttack: i32, myDefense: i32) bool
{
    var myLife: i32 = 100;
    var bossLife: i32 = bossHitPoints;
    
    while (true) 
    {    
        bossLife -= @max(1, myAttack - bossArmor);
        
        if (bossLife <= 0) { return true; }
    
        myLife -= @max(1, bossDamage - myDefense);
        
        if (myLife <= 0) { return false; }
    }
}

