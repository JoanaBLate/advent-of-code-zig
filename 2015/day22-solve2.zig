//! solution for https://adventofcode.com/2015/day/22 part 2

const std = @import("std");

const print = std.debug.print;

// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
// const allocator = arena.allocator();

const State = struct 
{
    heroLife: i32 =  50,
    heroMana: i32 = 500,
    spentMana: i32 =  0,
        
    bossLife: i32 = 0,

    shieldTurns: i32 = 0,
    poisonTurns: i32 = 0,
    rechargeTurns: i32 = 0
};

var bossHitPoints: i32 = 0;

var bossDamage: i32 = 0;

var lowestMana: i32 = 999999; // lowest mana with defeat


pub fn main() !void
{
 // defer arena.deinit();
    
    const rawData: []const u8 = @embedFile("day22-input.txt");

    const data: []const u8 = std.mem.trimRight(u8, rawData, "\n\r ");
    
    var lines = std.mem.splitAny(u8, data, "\n");
    
    const line1 = std.mem.trimRight(u8, lines.next().?, " ");
    const line2 = std.mem.trimRight(u8, lines.next().?, " ");

    var line1Tokens = std.mem.splitAny(u8, line1, " ");
    _ = line1Tokens.next(); // Hit
    _ = line1Tokens.next(); // Points:
    const hitPointsString = line1Tokens.next().?;
    bossHitPoints = try std.fmt.parseInt(i32, hitPointsString, 10);
    
    var line2Tokens = std.mem.splitAny(u8, line2, " ");
    _ = line2Tokens.next(); // Damage:
    const damageString = line2Tokens.next().?; 
    bossDamage = try std.fmt.parseInt(i32, damageString, 10);
    
    var initialState: State = undefined;
    
    initialState = createState();
    
    playHeroTurn(&initialState);

    print("answer: {}\n", .{ lowestMana });
}

fn createState() State
{
    return State{ .bossLife = bossHitPoints };
}

fn cloneState(source: *State) State
{
    var state = createState();
    
    state.heroLife = source.heroLife;
    state.heroMana = source.heroMana;
    state.spentMana = source.spentMana;
    
    state.bossLife = source.bossLife;
    
    state.shieldTurns = source.shieldTurns;
    state.poisonTurns = source.poisonTurns;
    state.rechargeTurns = source.rechargeTurns;

    return state;
}

fn basicUpdate(state: *State) void
{    
    if (state.poisonTurns > 0) { state.bossLife -= 3; }
    
    if (state.rechargeTurns > 0) { state.heroMana += 101; }
    
    if (state.shieldTurns > 0) { state.shieldTurns -= 1; }
    if (state.poisonTurns > 0) { state.poisonTurns -= 1; }
    if (state.rechargeTurns > 0) { state.rechargeTurns -= 1; }
}

fn tryBest(state: *State) void
{    
    if (state.spentMana < lowestMana) { lowestMana = state.spentMana; }
}

///////////////////////////////////////////////////////////////////////////////
      
fn playHeroTurn(state: *State) void // recursive function ( A calls B, B calls C, C calls A)
{
    state.heroLife -= 1;
    if (state.heroLife <= 0) { return; }
    
    basicUpdate(state);
    
    if (state.bossLife <= 0) { tryBest(state); return; } 
    
    castDrain(state);    
    castMissile(state);
    castPoison(state);
    castRecharge(state);
    castShield(state);
}

fn castDrain(currState: *State) void
{
    const mana = 73;

    if (currState.heroMana < mana) { return; }
    
    var newState = cloneState(currState);
    
    newState.heroMana -= mana;
    newState.spentMana += mana;
    
    newState.heroLife += 2;
    newState.bossLife -= 2;
    
    if (newState.bossLife <= 0) { tryBest(&newState); return; }
        
    playBossTurn(&newState);
}

fn castMissile(currState: *State) void
{
    const mana = 53;

    if (currState.heroMana < mana) { return; }
    
    var newState = cloneState(currState);
    
    newState.heroMana -= mana;
    newState.spentMana += mana;
    
    newState.bossLife -= 4;
    
    if (newState.bossLife <= 0) { tryBest(&newState); return; }
        
    playBossTurn(&newState);
}

fn castPoison(currState: *State) void
{
    const mana = 173;

    if (currState.heroMana < mana) { return; }
    
    if (currState.poisonTurns != 0) { return; }
    
    var newState = cloneState(currState);
    
    newState.heroMana -= mana;
    newState.spentMana += mana;
    
    newState.poisonTurns = 6;
        
    playBossTurn(&newState);
} 

fn castRecharge(currState: *State) void
{
    const mana = 229;

    if (currState.heroMana < mana) { return; }
    
    if (currState.rechargeTurns != 0) { return; }
    
    var newState = cloneState(currState);
    
    newState.heroMana -= mana;
    newState.spentMana += mana;
    
    newState.rechargeTurns = 5;
        
    playBossTurn(&newState);
}   

fn castShield(currState: *State) void
{
    const mana = 113;

    if (currState.heroMana < mana) { return; }
    
    if (currState.shieldTurns != 0) { return; }
    
    var newState = cloneState(currState);
    
    newState.heroMana -= mana;
    newState.spentMana += mana;
    
    newState.shieldTurns = 6;
        
    playBossTurn(&newState);
}

///////////////////////////////////////////////////////////////////////////////
        
fn playBossTurn(state: *State) void
{    
    if (state.spentMana >= lowestMana) { return; }    

    basicUpdate(state);
    
    if (state.bossLife <= 0) { tryBest(state); return; } 

    const defense: i32 = if (state.shieldTurns == 0) 0 else 7;
    
    const damage: i32 = @max(1, bossDamage - defense);
    
    state.heroLife -= damage;
    
    if (state.heroLife <= 0) { return; } 
    
    playHeroTurn(state);   
}

