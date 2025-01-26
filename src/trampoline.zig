const win32 = @import("zigwin32");
const std = @import("std");
const win = std.os.windows;
const mem = win32.system.memory;
// https://stackoverflow.com/a/60905849
pub fn detour(source: usize, destination: usize, len: comptime_int) bool {
    if (len < 5) return false;

    var current_protection: mem.PAGE_PROTECTION_FLAGS = .{};
    _ = mem.VirtualProtect(@as(*anyopaque, @ptrFromInt(source)), len, .{ .PAGE_EXECUTE_READWRITE = 1 }, &current_protection);
    
    const relative_addr: isize = @as(isize, @intCast(destination)) - @as(isize, @intCast(source)) - 5;

    @as(*u8, @ptrFromInt(source)).* = 0xE9;
    @as(*align(1) isize, @ptrFromInt(source + 1)).* = relative_addr;

    _ = mem.VirtualProtect(@as(*anyopaque, @ptrFromInt(source)), len, current_protection, &current_protection);

    return true;
}

pub fn trampoline_hook(source: usize, destination: usize, len: comptime_int) usize {
    if (len < 5) return false;
    const gateway: usize = @intFromPtr(mem.VirtualAlloc(null, len + 5, mem.VIRTUAL_ALLOCATION_TYPE{ .COMMIT = 1, .RESERVE = 1 }, mem.PAGE_EXECUTE_READWRITE));
   
    // comments spam so the formatter doesn't minify this code and make it unreadable
    @memcpy( //
        @as([*]u8, @ptrFromInt(gateway))[0..len], //
        @as([*]const u8, @ptrFromInt(source))[0..len] //
    );

    const gateway_relative_addr: usize = source - gateway - 5;
    @as(*u8, @ptrFromInt(gateway + len)).* = 0xE9;
    
    @as(*align(1) usize, @ptrFromInt(gateway + len + 1)).* = gateway_relative_addr;

    _ = detour(source, destination, len);
    return gateway;
}
