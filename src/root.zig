//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const win32 = @import("zigwin32");
const interface = @import("get_interface.zig");
const trampoline = @import("trampoline.zig");
const hooks = @import("hooks.zig");
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
    _ = win32.system.console.FreeConsole();
    const hInstCast: ?win.HINSTANCE = @ptrCast(hInst);
    win32.system.library_loader.FreeLibraryAndExitThread(hInstCast, 0);

    return 0;
}

fn load() void {
    _ = win32.system.console.AllocConsole();
}

fn main_thread(hInst: ?*anyopaque) callconv(std.builtin.CallingConvention.winapi) u32 {
    if (hInst == null)
        unreachable;

    load();

    // time for trampoline hook
    // CHLClient
    const g_pClient = interface.get_interface(*[*]usize, "client.dll", "VClient017").?.*;
    std.log.debug("g_pClient: {*}", .{g_pClient});

    const hud_process_input = g_pClient[10];
    std.log.debug("hud_process_input: {X}", .{hud_process_input});

    // // ... lol
    const g_pClientMode: [*]align(1) usize = @as(*align(1) *align(1) *align(1) [*]align(1) usize, @ptrFromInt(hud_process_input + 5)).*.*.*;

    std.log.debug("g_pClientMode: {*}", .{g_pClientMode});
    std.log.debug("CreateMove: {X}", .{g_pClientMode[21]});
    // const create_move: usize = @as(*usize, @ptrFromInt(g_pClientMode + 21 * 4)).*;
    // std.log.debug("CreateMove: {X}", .{create_move});

    // createmove:
    // 55                push    ebp
    // 8B EC             mov     ebp, esp
    // E8 88 E7 FB FF    call    getlocalplayer

    // hooks.create_move_o = @alignCast(@as(hooks.create_move_t, @ptrFromInt(trampoline.trampoline_hook(
    //     create_move,
    //     @intFromPtr(&hooks.hk_create_move),
    //     8,
    // ))));
    // hooks.create_move_o = @ptrCast(@as(*const anyopaque, @ptrFromInt(trampoline.trampoline_hook(create_move, @intFromPtr(&hooks.hk_create_move), 8))));

    return unload(hInst);
}
