//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const win32 = @import("zigwin32");
pub fn main() void {
    _ = win32.system.library_loader.LoadLibraryA("zigcssbt.dll");

    win32.system.threading.Sleep(5000);
}
