//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

const std = @import("std");

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("sdlzig_lib");
pub fn main() void {
    const result: i32 = lib.startGame();
    std.debug.print("{d}", .{result});
}
