const std = @import("std");
const win32 = @import("zigwin32");
const Interface = struct { create_fn: fn () callconv(.C) ?*anyopaque, name: []const u8 };

pub fn get_interface(mod: ?[*:0]const u8, interface: []const u8) ?u32 {
    const lib = win32.system.library_loader;
    const interface_fn: u32 = @intCast(@intFromPtr(lib.GetProcAddress(lib.GetModuleHandleA(mod), "CreateInterface")));
    if (interface_fn == 0)
        return null;

    const jump_start: u32 = interface_fn + 4;

    const ptr_jump: *u32 = @ptrFromInt(jump_start + 1);
    const jump_target: u32 = jump_start + ptr_jump.* + 5;

    const interface_list_ptr: *anyopaque = @ptrFromInt(jump_target + 6);
    const interface_list: [*]const Interface = @alignCast(@ptrCast(interface_list_ptr));

    for (0..50) |i| {
        const current_interface = interface_list[i]; //@ptrCast(@alignCast(@as(*u8, @ptrFromInt(jump_target + 6))));
        if (std.mem.eql(u8, current_interface.name, interface)) {
            const interface_ptr: usize = @intFromPtr(current_interface.create_fn());

            return interface_ptr;
        }
    }

    return null;
}
