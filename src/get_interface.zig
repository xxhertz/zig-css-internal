const std = @import("std");
const win32 = @import("zigwin32");

pub fn get_interface(comptime T: type, mod: ?[*:0]const u8, interface_name: [*:0]const u8) ?T {
    const lib = win32.system.library_loader;

    const create_interface: *const fn (name: [*:0]const u8, ret: ?*c_int) callconv(.C) T = @ptrCast(lib.GetProcAddress(lib.GetModuleHandleA(mod), "CreateInterface"));
    return create_interface(interface_name, null);
}
