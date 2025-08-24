//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cDefine("SDL_MAIN_HANDLED", {});
    @cInclude("SDL3/SDL_main.h");
});

const WIDTH = 1000;
const HEIGHT = 700;

const CONTAINER_WIDTH = 100;
const CONTAINER_HEIGHT = 150;
const CONTAINER_COLORS = [3][4]u8{ [4]u8{ 110, 115, 229, 90 }, [4]u8{ 229, 72, 51, 90 }, [4]u8{ 81, 255, 65, 100 } };
const BACKGROUND_COLOR = [4]u8{ 0x18, 0x18, 0x18, 0xFF };

const HELD_RECT = struct {
    held: bool,
    heldIndex: usize,
    deltaX: f32,
    deltaY: f32,
};
var HELD = HELD_RECT{
    .held = false,
    .heldIndex = 0,
    .deltaX = 0,
    .deltaY = 0,
};
var contactingRect = false;
var OVERLAP = sdl.SDL_FRect{ .x = 0, .y = 0, .w = CONTAINER_WIDTH, .h = CONTAINER_HEIGHT };

var RECTANGLES = [2]sdl.SDL_FRect{
    sdl.SDL_FRect{ .x = 0, .y = 0, .w = CONTAINER_WIDTH, .h = CONTAINER_HEIGHT },
    sdl.SDL_FRect{ .x = 0, .y = 0, .w = CONTAINER_WIDTH, .h = CONTAINER_HEIGHT },
};

pub export fn startGame() i32 {
    var result: i32 = 0;
    main_game() catch |err| switch (err) {
        error.VideoInitFailed => result = 1,
        error.WindowInitFailed => result = 2,
        error.RendererFailed => result = 3,
        else => unreachable,
    };
    return result;
}

pub fn main_game() !void {
    printout("Importing SDL");
    errdefer (printout("error occurred during the import"));

    // setup
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != true) {
        printout("Failed to start the video");
        return error.VideoInitFailed;
    }
    //defer sdl.SDL_EVENT_QUIT();

    const window = sdl.SDL_CreateWindow("ZIG SDL", WIDTH, HEIGHT, sdl.SDL_WINDOW_MAXIMIZED) orelse {
        printout("Failed to start the window");
        return error.WindowInitFailed;
    };
    defer sdl.SDL_DestroyWindow(window);

    const renderer = sdl.SDL_CreateRenderer(window, null) orelse {
        printout("Failed to start the renderer");
        return error.RendererFailed;
    };
    _ = sdl.SDL_SetRenderDrawColor(renderer, 0x18, 0x18, 0x18, 0xFF);
    _ = sdl.SDL_RenderClear(renderer);

    var gameActive = true;
    for (0..RECTANGLES.len) |c| {
        RECTANGLES[c].x = @floatFromInt(c * 200 + 50);
        RECTANGLES[c].y = @floatFromInt(200 + c * 10);
    }
    while (gameActive == true) {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != false) {
            gameActive = eventManager(&event);
            gamePlay(renderer, event);
            _ = sdl.SDL_RenderPresent(renderer);
        }
    }

    printout("....Completed successfully");
}

fn gamePlay(renderer: *sdl.SDL_Renderer, event: sdl.SDL_Event) void {
    // Background
    _ = sdl.SDL_SetRenderDrawColor(renderer, BACKGROUND_COLOR[0], BACKGROUND_COLOR[1], BACKGROUND_COLOR[2], BACKGROUND_COLOR[3]);
    _ = sdl.SDL_RenderClear(renderer);

    // Managing the moving rectangle
    if (HELD.held == true) {
        var movedRect: *sdl.SDL_FRect = &RECTANGLES[HELD.heldIndex];
        movedRect.x = (event.button.x - HELD.deltaX);
        movedRect.y = (event.button.y - HELD.deltaY);
        contactingRect = contactCheck();
    }
    if (contactingRect) {
        printout("Collission!");
        _ = sdl.SDL_SetRenderDrawColor(renderer, CONTAINER_COLORS[2][0], CONTAINER_COLORS[2][1], CONTAINER_COLORS[2][2], CONTAINER_COLORS[2][3]);
        _ = sdl.SDL_RenderFillRect(renderer, &OVERLAP);
    }

    // Rectangles to move
    for (0..RECTANGLES.len) |c| {
        var rect: sdl.SDL_FRect = RECTANGLES[c];
        _ = sdl.SDL_SetRenderDrawColor(renderer, CONTAINER_COLORS[c][0], CONTAINER_COLORS[c][1], CONTAINER_COLORS[c][2], CONTAINER_COLORS[c][3]);
        _ = sdl.SDL_RenderRect(renderer, &rect);
    }
}

fn eventManager(event: *sdl.SDL_Event) bool {
    switch (event.type) {
        sdl.SDL_EVENT_QUIT => {
            return false;
        },
        sdl.SDL_EVENT_MOUSE_BUTTON_DOWN => {
            //printout("Mouse clicked : X = " ++ event.button.x ++ " | Y = " ++ event.button.y);
            //printoutf("Mouse DOWN", event.button.x, event.button.y);
            HELD.held = wasRectangleClicked(event.button.x, event.button.y);
            if (HELD.held) {
                printout("held");
            }
        },
        sdl.SDL_EVENT_MOUSE_BUTTON_UP => {
            //printoutf("Mouse UP", event.button.x, event.button.y);
            if (HELD.held) {
                HELD.held = false;
            }
        },
        sdl.SDL_EVENT_MOUSE_MOTION => {
            if (HELD.held == true) {
                printoutf("Dragging", event.button.x, event.button.y);
            }
        },
        else => {},
    }
    return true;
}

fn wasRectangleClicked(x: f32, y: f32) bool {
    for (RECTANGLES, 0..) |dz, index| {
        if (x < dz.x) continue;
        if (y < dz.y) continue;
        if (x > (dz.x + CONTAINER_WIDTH)) continue;
        if (y > (dz.y + CONTAINER_HEIGHT)) continue;
        HELD.heldIndex = @intCast(index);
        HELD.deltaX = x - dz.x;
        HELD.deltaY = y - dz.y;
        return true;
    }
    return false;
}

fn contactCheck() bool {
    if ((RECTANGLES[0].x + CONTAINER_WIDTH) < RECTANGLES[1].x) return false;
    if ((RECTANGLES[0].y + CONTAINER_HEIGHT) < RECTANGLES[1].y) return false;
    if ((RECTANGLES[1].x + CONTAINER_WIDTH) < RECTANGLES[0].x) return false;
    if ((RECTANGLES[1].y + CONTAINER_HEIGHT) < RECTANGLES[0].y) return false;
    if (RECTANGLES[0].x > RECTANGLES[1].x) {
        OVERLAP.w = RECTANGLES[1].x - RECTANGLES[0].x + CONTAINER_WIDTH;
        OVERLAP.x = RECTANGLES[0].x;
    } else {
        OVERLAP.w = RECTANGLES[0].x - RECTANGLES[1].x + CONTAINER_WIDTH;
        OVERLAP.x = RECTANGLES[1].x;
    }

    if (RECTANGLES[0].y > RECTANGLES[1].y) {
        OVERLAP.h = RECTANGLES[1].y - RECTANGLES[0].y + CONTAINER_HEIGHT;
        OVERLAP.y = RECTANGLES[0].y;
    } else {
        OVERLAP.h = RECTANGLES[0].h - RECTANGLES[1].h + CONTAINER_HEIGHT;
        OVERLAP.y = RECTANGLES[1].y;
    }

    contactingRect = true;
    return true;
}


// Just lazy, easier to have functions to abstract the calls
fn printout(message: []const u8) void {
    std.debug.print("{s}\n", .{message});
}

fn printouti(message: []const u8, x: usize, y: usize) void {
    std.debug.print("{s} - x= {d} | y= {d} \n", .{ message, x, y });
}
fn printoutf(message: []const u8, x: f32, y: f32) void {
    const xu: usize = @intFromFloat(x);
    const yu: usize = @intFromFloat(y);
    std.debug.print("{s} - x= {d} | y= {d} \n", .{ message, xu, yu });
}
