const win32 = @import("zigwin32");
const std = @import("std");
const win = std.os.windows;
const mem = win32.system.memory;
const hook_state = @import("structs.zig").hook_state;

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

// no idea how safe this is but it works like a charm
pub fn virtual_hook(vtable: [*]align(1) usize, index: u32, hook_ptr: usize) usize {
    const original_ptr: usize = vtable[index];
    global_hooks_states.list.append(.{ .index = index, .original_ptr = original_ptr, .vtable = vtable }) catch @panic("error: either you forgot to initialize global_hooks_states, or some other error with the allocator occured");

    var old_protection: mem.PAGE_PROTECTION_FLAGS = .{};
    _ = mem.VirtualProtect(&vtable[index], @sizeOf(usize), .{ .PAGE_READWRITE = 1 }, &old_protection);
    vtable[index] = hook_ptr;
    _ = mem.VirtualProtect(&vtable[index], @sizeOf(usize), old_protection, &old_protection);

    return original_ptr;
}
