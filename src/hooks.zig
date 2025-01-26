const vec3 = @import("vector.zig").vec3;

pub const c_usercmd = struct {
    _: u32, // padding for destructor, 4bytes
    command_number: c_int, //4
    tick_count: c_int, //8
    viewangles: vec3, //C
    forwardmove: f32, //18
    sidemove: f32, //1C
    upmove: f32, //20
    buttons: c_int, //24
    impulse: u8, //28
    weaponselect: c_int, //2C
    weaponsubtype: c_int, //30
    random_seed: c_int, //34
    mousedx: c_short, //38
    mousedy: c_short, //3A
    hasbeenpredicted: bool, //3C;
};

pub const userButtons = enum(u8) {
    IN_ATTACK = (1 << 0),
    IN_JUMP = (1 << 1),
    IN_DUCK = (1 << 2),
    IN_FORWARD = (1 << 3),
    IN_BACK = (1 << 4),
    IN_USE = (1 << 5),
    IN_CANCEL = (1 << 6),
    IN_LEFT = (1 << 7),
    IN_RIGHT = (1 << 8),
    IN_MOVELEFT = (1 << 9),
    IN_MOVERIGHT = (1 << 10),
    IN_ATTACK2 = (1 << 11),
    IN_RUN = (1 << 12),
    IN_RELOAD = (1 << 13),
    IN_ALT1 = (1 << 14),
    IN_ALT2 = (1 << 15),
    IN_SCORE = (1 << 16), // Used by client.dll for when scoreboard is held down
    IN_SPEED = (1 << 17), // Player is holding the speed key
    IN_WALK = (1 << 18), // Player holding walk key
    IN_ZOOM = (1 << 19), // Zoom key for HUD zoom
    IN_WEAPON1 = (1 << 20), // weapon defines these bits
    IN_WEAPON2 = (1 << 21), // weapon defines these bits
    IN_BULLRUSH = (1 << 22),
};

const flags = enum(u8) {
    FL_ONGROUND = (1 << 0), // At rest / on the ground
    FL_DUCKING = (1 << 1), // Player flag -- Player is fully crouched
    FL_WATERJUMP = (1 << 2), // player jumping out of water
    FL_ONTRAIN = (1 << 3), // Player is _controlling_ a train, so movement commands should be ignored on client during prediction.
    FL_INRAIN = (1 << 4), // Indicates the entity is standing in rain
    FL_FROZEN = (1 << 5), // Player is frozen for 3rd person camera
    FL_ATCONTROLS = (1 << 6), // Player can't move, but keeps key inputs for controlling another entity
    FL_CLIENT = (1 << 7), // Is a player
    FL_FAKECLIENT = (1 << 8), // Fake client, simulated server side; don't send network messages to them
    // NON-PLAYER SPECIFIC (i.e., not used by GameMovement or the client .dll ) -- Can still be applied to players, though
    FL_INWATER = (1 << 9), // In water
    FL_FLY = (1 << 10), // Changes the SV_Movestep() behavior to not need to be on ground
    FL_SWIM = (1 << 11), // Changes the SV_Movestep() behavior to not need to be on ground (but stay in water)
    FL_CONVEYOR = (1 << 12),
    FL_NPC = (1 << 13),
    FL_GODMODE = (1 << 14),
    FL_NOTARGET = (1 << 15),
    FL_AIMTARGET = (1 << 16), // set if the crosshair needs to aim onto the entity
    FL_PARTIALGROUND = (1 << 17), // not all corners are valid
    FL_STATICPROP = (1 << 18), // Eetsa static prop!
    FL_GRAPHED = (1 << 19), // worldgraph has this ent listed as something that blocks a connection
    FL_GRENADE = (1 << 20),
    FL_STEPMOVEMENT = (1 << 21), // Changes the SV_Movestep() behavior to not do any processing
    FL_DONTTOUCH = (1 << 22), // Doesn't generate touch functions, generates Untouch() for anything it was touching when this flag was set
    FL_BASEVELOCITY = (1 << 23), // Base velocity has been applied this frame (used to convert base velocity into momentum)
    FL_WORLDBRUSH = (1 << 24), // Not moveable/removeable brush entity (really part of the world, but represented as an entity for transparency or something)
    FL_OBJECT = (1 << 25), // Terrible name. This is an object that NPCs should see. Missiles, for example.
    FL_KILLME = (1 << 26), // This entity is marked for death -- will be freed by game DLL
    FL_ONFIRE = (1 << 27), // You know...
    FL_DISSOLVING = (1 << 28), // We're dissolving!
    FL_TRANSRAGDOLL = (1 << 29), // In the process of turning into a client side ragdoll.
    FL_UNBLOCKABLE_BY_PLAYER = (1 << 30), // pusher that can't be blocked by the player
};

pub const create_move_t = fn (_: *anyopaque, _: f32, cmd: *c_usercmd) callconv(.C) bool;
pub var create_move_o: create_move_t = null;

const std = @import("std");
pub fn hk_create_move(this_ptr: *anyopaque, frametime: f32, cmd: *c_usercmd) callconv(.C) bool {
    std.log.debug("I LOVE CREATEMOVE :D", .{});
    return create_move_t(this_ptr, frametime, cmd);
}
