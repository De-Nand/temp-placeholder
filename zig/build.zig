const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Frankly flip-flopping between simulator/ios is not "clear"
    // This is just an alternative where I have my own build flag to go one direction or another
    const use_simulator = b.option(bool, "sim", "uses sim") orelse false;
    const ios = b.option(bool, "ios", "ios device?") orelse false;

    // Registering the Library
    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Registering the Executable so the library can be tested on a computer
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("sdlzig_lib", lib_mod);

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "sdlzig_lib",
        .root_module = lib_mod,
    });

    const exe = b.addExecutable(.{ .name = "sdlzig", .root_source_file = b.path("src/main.zig"), .optimize = optimize, .root_module = exe_mod });

    // Mac
    if (builtin.target.os.tag != .windows) {
        if (ios) {
            const sdl_path = "../sdls";
            lib.addIncludePath(.{ .cwd_relative = sdl_path ++ "/headers" });
            lib.addIncludePath(.{ .cwd_relative = sdl_path ++ "/headers" });
            if (use_simulator) {
                // zig build -Dtarget=aarch64-ios-simulator -Dsim=true -Dios=true
                const sim_sdk_path = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator18.2.sdk";
                lib.addSystemIncludePath(.{ .cwd_relative = sim_sdk_path ++ "/usr/include" });
                lib.addLibraryPath(.{ .cwd_relative = sim_sdk_path ++ "/usr/lib" });
                lib.addLibraryPath(.{ .cwd_relative = sdl_path ++ "/sim" });
            } else {
                // zig build -Dtarget=aarch64-ios -Dsim=false -Dios=true
                const sim_sdk_path = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.2.sdk";
                lib.addSystemIncludePath(.{ .cwd_relative = sim_sdk_path ++ "/usr/include" });
                lib.addLibraryPath(.{ .cwd_relative = sim_sdk_path ++ "/usr/lib" });
                lib.addLibraryPath(.{ .cwd_relative = sdl_path ++ "/ios" });
            }

            const install = b.addInstallArtifact(lib, .{
                .dest_dir = .{ .override = .{ .custom = "../../xcode/game/lib " } },
            });
            b.default_step.dependOn(&install.step);
        } else {
            // Default path for mac desktop, using the homebrew install
            const sdl_path = "/opt/homebrew/include";
            const sdl_lib_path = "/opt/homebrew/Cellar/sdl3/3.2.16/lib";
            lib.addIncludePath(.{ .cwd_relative = sdl_path });
            lib.addLibraryPath(.{ .cwd_relative = sdl_lib_path });
        }

        lib.linkSystemLibrary("System");
        lib.linkSystemLibrary("SDL3");
    } else {
        // Default Windows
        // todo!
    }

    lib.linkLibC();
    exe.linkLibC();
    b.installArtifact(lib);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
