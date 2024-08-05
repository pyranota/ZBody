const std = @import("std");

const modules = .{
    @import("showcase/mod.zig"),
    // @import("settings/mod.zig"),
};

// fn toUpperCase(input: []const u8) []u8 {
//     var allocator = std.heap.page_allocator;
//     var output = try allocator.alloc(u8, input.len);

//     for (input, 0..) |c, i| {
//         // Convert to uppercase
//         if (c >= 'a' and c <= 'z') {
//             output[i] = c - ('a' - 'A');
//         } else {
//             output[i] = c; // Keep the character as is if it's not a lowercase letter
//         }
//     }

//     return output;
// }

/// *mod_name* should be lowercase and reflect directory where files are sitting
pub inline fn import(comptime mod_name: []const u8) type {
    // e.g. "EXAMPLE"         ^^^^^^^^ e.g. "example"
    const mod_name_upper = inner: {
        var output: [mod_name.len]u8 = undefined;
        for (mod_name, 0..) |c, i| {
            // Convert to uppercase
            if (c >= 'a' and c <= 'z')
                output[i] = c - ('a' - 'A')
            else
                output[i] = c; // Keep the character as is if it's not a lowercase letter
        }
        break :inner output[0..]; // Return a slice of the output array
    };

    // e.g. "Example"
    const mod_name_cased = inner: {
        var output: [mod_name.len]u8 = undefined;
        for (mod_name, 0..) |c, i| {
            // Convert to uppercase only first character
            if (i == 0)
                output[i] = c - ('a' - 'A')
            else
                output[i] = c; // Keep the character as is if it's not a lowercase letter
        }
        break :inner output[0..]; // Return a slice of the output array
    };

    const GUI_IMPLEMENTATION = std.fmt.comptimePrint( //
        "GUI_{s}_IMPLEMENTATION", //
        .{mod_name_upper});

    const HEADER_FILE_PATH = std.fmt.comptimePrint( //
        "{s}/mod.h", //
        .{mod_name});
    _ = HEADER_FILE_PATH; // autofix

    const GUI_UPDATE = std.fmt.comptimePrint( //
        "Gui{s}", //
        .{mod_name_cased});

    const STATE = comptime inner: {
        break :inner std.fmt.comptimePrint( //
            "Gui{s}State", //
            .{mod_name_cased});
    };

    const INIT_GUI = std.fmt.comptimePrint( //
        "InitGui{s}", //
        .{mod_name_cased});

    return struct {
        pub const c = @cImport({
            @cDefine(GUI_IMPLEMENTATION, {});
            @cInclude("./showcase/mod.h");
        });

        pub const GuiUpdate = //
            @field(c, GUI_UPDATE);

        pub const State = @field(c, STATE);
        pub var s: State = undefined;

        pub fn init() void {
            s = @field(c, INIT_GUI)();
        }
    };
}

// const c = @cImport({
//     for (0..1) |i| {
//         _ = i; // autofix
//         const mod_name = "showcase";
//         const mod_name_upper = "SHOWCASE";

//         const DEF = std.fmt.comptimePrint( //
//             "GUI_{s}_IMPLEMENTATION", //
//             .{mod_name_upper});

//         @cDefine(DEF, {});

//         // const inf = in();
//         // const path = std.fs.path.dirname(inf.file);

//         // Open the current working directory

//         // std.debug.print("Path: {s}", .{path});

//         const HNAME = std.fmt.comptimePrint( //
//             "{s}.h", //
//             .{mod_name});

//         @cInclude(HNAME);
//     }
// });

pub fn init() void {
    inline for (modules) |mod|
        mod.im.init();
}

/// Draw UI
/// Should be called after camera mode
pub fn draw() void {
    inline for (modules) |mod| {
        mod.im.GuiUpdate(@ptrCast(&mod.im.s));

        // TODO: Alternatively call without args.
        mod.update(&mod.im.s);
    }
}
