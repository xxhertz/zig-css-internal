//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const win32 = @import("zigwin32");
const interface = @import("get_interface.zig");
const trampoline = @import("trampoline.zig");
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
    // const g_pClient = interface.get_interface(*usize, "client.dll", "VClient017") orelse return unload(hInst);
    // std.log.debug("g_pClient: {X}", .{g_pClient.*});

    // const hud_process_input: usize = @as(*usize, @ptrFromInt(g_pClient.* + 40)).*; // equivalent of indexing by 10 (4 bytes per func)
    // std.log.debug("hud_process_input: {X}", .{hud_process_input});

    // zig does not like misaligned bytes so i got a bit lazy i should fix this tmr tbh
    // const bytes: *const [4]u8 = @ptrFromInt(hud_process_input + 5);
    // also i dont think these need to be u32 but it worked last time i ran it, i believe usize and u32 should function the same but i really don't care enough to try right
    // const g_pClientMode: u32 = @as(**u32, @ptrFromInt(@as(u32, @bitCast(bytes.*)))).*.*;
    // std.log.debug("g_pClientMode: {X}", .{g_pClientMode});

    // const create_move: u32 = @as(*usize, @ptrFromInt(g_pClientMode + 21 * 4)).*;
    // std.log.debug("CreateMove: {X}", .{create_move});

    return unload(hInst);
}
