const c_usercmd = @import("structs.zig").c_usercmd;
const globals = @import("globals.zig");
pub const create_move_t = *const fn (_: f32, _: *c_usercmd) callconv(.Stdcall) bool;
pub var create_move_o: create_move_t = undefined;

const std = @import("std");
pub fn hk_create_move(frametime: f32, cmd: *c_usercmd) callconv(.Stdcall) bool {
    const local_player = globals.get_local_player().?;
    cmd.buttons.IN_JUMP = cmd.buttons.IN_JUMP and local_player.m_iFlags.FL_ONGROUND;

    return create_move_o(frametime, cmd);
}
