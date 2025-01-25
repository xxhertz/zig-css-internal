//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const win32 = @import("zigwin32");
const interface = @import("get_interface.zig");
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

    // CHLClient
    const g_pClient = interface.get_interface("client", "VClient");
    if (g_pClient == null)
        return unload(hInst);

    
    // const vftable: [*c](fn () callconv(.C) void) = @ptrFromInt(g_pClient.?);
    // const hud_process_input: usize = @intFromPtr(vftable[10]);
    // _ = hud_process_input;
    // const hud_process_input: usize = @intFromPtr((@as(*[]*anyopaque, @ptrFromInt(g_pClient.?))).*)[10];
    // const g_pClientMode: ?*anyopaque = @as(***anyopaque, @ptrFromInt(hud_process_input + 5)).*.*;
    // if (g_pClientMode == null)
    //     return unload(hInst);

    return unload(hInst);
}
