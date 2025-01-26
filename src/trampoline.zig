const win32 = @import("zigwin32");
const std = @import("std");
const win = std.os.windows;
const mem = win32.system.memory;
// https://stackoverflow.com/a/60905849
pub fn detour(source: usize, destination: usize, len: comptime_int) bool {
    if (len < 5) return false;

    var current_protection: ?win.DWORD = null;
    _ = mem.VirtualProtect(source, len, mem.PAGE_EXECUTE_READWRITE, &current_protection);

    const relative_addr: usize = destination - source - 5;

    @as(*u8, @ptrFromInt(source)).* = 0xE9;
    @as(*usize, @ptrFromInt(source + 1)).* = relative_addr;

    _ = mem.VirtualProtect(source, len, current_protection, &current_protection);

    return true;
}

pub fn trampoline_hook(source: usize, destination: usize, len: comptime_int) usize {
    if (len < 5) return false;

    const gateway: usize = mem.VirtualAlloc(null, len + 5, mem.MEM_COMMIT | mem.MEM_RESERVE, mem.PAGE_EXECUTE_READWRITE);
    // comments spam so the formatter doesn't minify this code and make it unreadable
    @memcpy( //
        @as([*]u8, @ptrFromInt(gateway))[0..len], //
        @as([*]const u8, @ptrFromInt(source))[0..len] //
    );

    const gateway_relative_addr: usize = source - gateway - 5;
    @as(*u8, @ptrFromInt(gateway + len)).* = 0xE9;

    @as(*usize, @ptrFromInt(gateway + len + 1)).* = gateway_relative_addr;

    _ = detour(source, destination, len);
    return gateway;
}
