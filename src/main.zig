//! WebUI Zig - Minimal Example
const webui = @import("webui");
const std = @import("std");

pub fn main() !void {
    // create a new window
    var nwin = webui.newWindow();
    const suc = nwin.show("<html><head><script src=\"webui.js\"></script></head> Hello World ! </html>");
    std.debug.print("{}", .{suc});
    webui.wait();
}
