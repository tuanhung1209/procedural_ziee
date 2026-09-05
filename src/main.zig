const std = @import("std");
const TreeApp = @import("vulkan/tree_application.zig").TreeApp;

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var app: TreeApp = .{};
    if (app.init(allocator)) {
        app.run();
    }
    app.deinit();
}
