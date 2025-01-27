const vec3 = @import("vector.zig").vec3;

pub const c_usercmd = struct {
    _: u32, // padding for destructor, 4bytes
    command_number: c_int, //4
    tick_count: c_int, //8
    viewangles: vec3, //C
    forwardmove: f32, //18
    sidemove: f32, //1C
    upmove: f32, //20
    buttons: user_buttons, //24
    impulse: u8, //28
    weaponselect: c_int, //2C
    weaponsubtype: c_int, //30
    random_seed: c_int, //34
    mousedx: c_short, //38
    mousedy: c_short, //3A
    hasbeenpredicted: bool, //3C;
};

pub const user_buttons = packed struct(u23) {
    IN_ATTACK: u1 = 0,
    IN_JUMP: u1 = 0,
    IN_DUCK: u1 = 0,
    IN_FORWARD: u1 = 0,
    IN_BACK: u1 = 0,
    IN_USE: u1 = 0,
    IN_CANCEL: u1 = 0,
    IN_LEFT: u1 = 0,
    IN_RIGHT: u1 = 0,
    IN_MOVELEFT: u1 = 0,
    IN_MOVERIGHT: u1 = 0,
    IN_ATTACK2: u1 = 0,
    IN_RUN: u1 = 0,
    IN_RELOAD: u1 = 0,
    IN_ALT1: u1 = 0,
    IN_ALT2: u1 = 0,
    IN_SCORE: u1 = 0,
    IN_SPEED: u1 = 0,
    IN_WALK: u1 = 0,
    IN_ZOOM: u1 = 0,
    IN_WEAPON1: u1 = 0,
    IN_WEAPON2: u1 = 0,
    IN_BULLRUSH: u1 = 0,
};
pub const flags = packed struct(u32) {
    FL_ONGROUND: u1 = 0,
    FL_DUCKING: u1 = 0,
    FL_WATERJUMP: u1 = 0,
    FL_ONTRAIN: u1 = 0,
    FL_INRAIN: u1 = 0,
    FL_FROZEN: u1 = 0,
    FL_ATCONTROLS: u1 = 0,
    FL_CLIENT: u1 = 0,
    FL_FAKECLIENT: u1 = 0,
    FL_INWATER: u1 = 0,
    FL_FLY: u1 = 0,
    FL_SWIM: u1 = 0,
    FL_CONVEYOR: u1 = 0,
    FL_NPC: u1 = 0,
    FL_GODMODE: u1 = 0,
    FL_NOTARGET: u1 = 0,
    FL_AIMTARGET: u1 = 0,
    FL_PARTIALGROUND: u1 = 0,
    FL_STATICPROP: u1 = 0,
    FL_GRAPHED: u1 = 0,
    FL_GRENADE: u1 = 0,
    FL_STEPMOVEMENT: u1 = 0,
    FL_DONTTOUCH: u1 = 0,
    FL_BASEVELOCITY: u1 = 0,
    FL_WORLDBRUSH: u1 = 0,
    FL_OBJECT: u1 = 0,
    FL_KILLME: u1 = 0,
    FL_ONFIRE: u1 = 0,
    FL_DISSOLVING: u1 = 0,
    FL_TRANSRAGDOLL: u1 = 0,
    FL_UNBLOCKABLE_BY_PLAYER: u1 = 0,
};

pub const create_move_t = *const fn (_: f32, _: *c_usercmd) callconv(.Stdcall) bool;
pub var create_move_o: ?create_move_t = null;

const std = @import("std");
pub fn hk_create_move(frametime: f32, cmd: *c_usercmd) callconv(.Stdcall) bool {
    std.log.debug("I LOVE CREATEMOVE :D\nhk: {X}\norig: {X}", .{ @intFromPtr(&hk_create_move), @intFromPtr(create_move_o) });

    std.log.debug("shooting: {x}", .{cmd.buttons.IN_ATTACK});
    std.log.debug("view: {} {} {}", .{ cmd.viewangles.x, cmd.viewangles.y, cmd.viewangles.z });
    // std.debug.print("hk_create_move: {X}\ncreate_move_o: {?X}", .{ @intFromPtr(&hk_create_move), @intFromPtr(&create_move_o) });
    return create_move_o.?(frametime, cmd);
}
