//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const win32 = @import("zigwin32");

pub fn doAnotherThing() void {
    std.log.debug("hello :D", .{});
}

pub fn doAThing(_: ?*anyopaque) callconv(std.builtin.CallingConvention.winapi) u32 {
    while (true) {
        doAnotherThing();

        win32.system.threading.Sleep(500);
    }

    return 0;
}

pub fn main() void {
    _ = win32.system.threading.CreateThread(null, 0, doAThing, null, win32.system.threading.THREAD_CREATE_RUN_IMMEDIATELY, null);
    win32.system.threading.Sleep(1000);
    std.log.debug("loading library", .{});
    _ = win32.system.library_loader.LoadLibraryA("zigcssbt.dll");

    win32.system.threading.Sleep(1500);
}
