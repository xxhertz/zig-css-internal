const std = @import("std");
const win32 = @import("zigwin32");
const interface = @import("get_interface.zig");
const hooking = @import("vmthook");
const structs = @import("structs.zig");
const hooks = @import("hooks.zig");
const globals = @import("globals.zig");
const win = std.os.windows;

pub export fn DllMain(hInst: win.HINSTANCE, dwReason: win.DWORD, _: win.LPVOID) win.BOOL {
    const services = win32.system.system_services;

    switch (dwReason) {
        services.DLL_PROCESS_ATTACH => {
            _ = win32.system.library_loader.DisableThreadLibraryCalls(hInst);
            const thread = win32.system.threading.CreateThread(null, 0, main_thread, hInst, win32.system.threading.THREAD_CREATE_RUN_IMMEDIATELY, null);
            if (thread == null)
                return win.FALSE; // failed

            _ = win32.foundation.CloseHandle(thread);
        },
        else => {},
    }
    return win.TRUE;
}

fn unload(hInst: ?*anyopaque) u32 {
    _ = std.io.getStdIn().reader().readByte() catch unreachable;
    hooking.deinit();
    _ = win32.system.console.FreeConsole();
    const hInstCast: ?win.HINSTANCE = @ptrCast(hInst);
    win32.system.library_loader.FreeLibraryAndExitThread(hInstCast, 0);

    return 0;
}

fn main_thread(hInst: ?*anyopaque) callconv(.winapi) u32 {
    if (hInst == null)
        unreachable;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    hooking.init(allocator);

    _ = win32.system.console.AllocConsole();

    // CHLClient
    const g_pClient = interface.get_interface(*[*]usize, "client.dll", "VClient017").?.*;
    std.log.debug("CHLClient: {*}", .{g_pClient});

    const hud_process_input = g_pClient[10];
    std.log.debug("CHLClient->HudProcessInput: {X}", .{hud_process_input});

    // ... lol
    const g_pClientMode: [*]align(1) usize = @as(*align(1) *align(1) *align(1) [*]align(1) usize, @ptrFromInt(hud_process_input + 5)).*.*.*;
    std.log.debug("g_pClientMode: {*}", .{g_pClientMode});

    const create_move = g_pClientMode[21];
    std.log.debug("g_pClientMode->CreateMove: {X}", .{create_move});

    globals.get_local_player = @ptrFromInt(@as(usize, @intCast(@as(isize, @intCast(create_move + 8)) + @as(*isize, @ptrFromInt(create_move + 4)).*)));
    std.log.debug("C_BasePlayer->GetLocalPlayer: {X}", .{globals.get_local_player});

    hooks.create_move_o = @ptrCast(hooking.virtual_hook(g_pClientMode, 21, &hooks.hk_create_move));

    return unload(hInst);
}
