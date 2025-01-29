const win32 = @import("zigwin32");
const std = @import("std");
const win = std.os.windows;
const mem = win32.system.memory;
const hook_state = @import("structs.zig").hook_state;
// https://stackoverflow.com/a/60905849
// im pretty sure my implementation is perfect?
// although it won't work for my use-case because createmove has a call at the 4th byte meaning
// i can't programmatically, simply, and cleanly reorder the call relative address to be at the new location
// *assuming that is the problem, i am not even sure if CALL takes a relative addr as an operand or if DeepSeek was hallucinating when i asked if it did
// so i guess i have trampoline hook implemented for no reason LOL
pub fn detour(source: usize, destination: usize, len: comptime_int) bool {
    if (len < 5) return false;

    var old_protection: mem.PAGE_PROTECTION_FLAGS = .{};
    _ = mem.VirtualProtect(@as(*anyopaque, @ptrFromInt(source)), len, .{ .PAGE_EXECUTE_READWRITE = 1 }, &old_protection);

    const relative_addr: isize = @as(isize, @intCast(destination)) - @as(isize, @intCast(source)) - 5;

    @as(*u8, @ptrFromInt(source)).* = 0xE9;
    @as(*align(1) isize, @ptrFromInt(source + 1)).* = relative_addr;

    _ = mem.VirtualProtect(@as(*anyopaque, @ptrFromInt(source)), len, old_protection, &old_protection);

    return true;
}

pub fn trampoline_hook(source: usize, destination: usize, len: comptime_int) usize {
    if (len < 5) return false;
    
    const gateway: usize = @intFromPtr(mem.VirtualAlloc(null, len + 5, mem.VIRTUAL_ALLOCATION_TYPE{ .COMMIT = 1, .RESERVE = 1 }, mem.PAGE_EXECUTE_READWRITE));

    @memcpy(
        @as([*]u8, @ptrFromInt(gateway))[0..len],
        @as([*]const u8, @ptrFromInt(source))[0..len],
    );
    const gateway_relative_addr: isize = @intCast(@as(isize, @intCast(source)) - @as(isize, @intCast(gateway)) - 5);

    @as(*u8, @ptrFromInt(gateway + len)).* = 0xE9;
    @as(*align(1) isize, @ptrFromInt(gateway + len + 1)).* = gateway_relative_addr;

    _ = detour(source, destination, len);
    return gateway;
}

// i dont care to implement this (unhooking) for trampoline hooks since i'm not using them in this project anyways
pub const global_hooks_states = struct {
    var list: std.ArrayList(hook_state) = undefined;
    var allocator: std.mem.Allocator = undefined;

    pub fn init(alloc: std.mem.Allocator) void {
        global_hooks_states.list = std.ArrayList(hook_state).init(alloc);
        global_hooks_states.allocator = alloc;
    }

    pub fn deinit() void {
        for (global_hooks_states.list.items) |hook_data| {
            var old_protection: mem.PAGE_PROTECTION_FLAGS = .{};
            _ = mem.VirtualProtect(&hook_data.vtable[hook_data.index], @sizeOf(usize), .{ .PAGE_READWRITE = 1 }, &old_protection);
            hook_data.vtable[hook_data.index] = hook_data.original_ptr;
            _ = mem.VirtualProtect(&hook_data.vtable[hook_data.index], @sizeOf(usize), old_protection, &old_protection);
        }
    }
};

pub fn virtual_hook(vtable: [*]align(1) usize, index: u32, hook_ptr: usize) usize {
    const original_ptr: usize = vtable[index];
    global_hooks_states.list.append(.{ .index = index, .original_ptr = original_ptr, .vtable = vtable }) catch @panic("error: either you forgot to initialize global_hooks_states, or some other error with the allocator occured");

    var old_protection: mem.PAGE_PROTECTION_FLAGS = .{};
    _ = mem.VirtualProtect(&vtable[index], @sizeOf(usize), .{ .PAGE_READWRITE = 1 }, &old_protection);
    vtable[index] = hook_ptr;
    _ = mem.VirtualProtect(&vtable[index], @sizeOf(usize), old_protection, &old_protection);

    return original_ptr;
}
