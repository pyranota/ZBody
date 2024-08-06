const State = @import("../c.zig").SettingsState;

const std = @import("std");

pub fn update(s: *State) void {
    _ = s; // autofix
}

// TODO: Can also be:
// const Self = @This();
// local_state: u32 = 0,
// pub fn update(self: Self, s: *State) void {
//   local_state += 1;
// }
