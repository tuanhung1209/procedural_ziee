const TreeApp = @import("vulkan/tree_application.zig").TreeApp;

pub fn main() void {
    var app: TreeApp = .{};
    if (app.init()) {
        app.run();
    }
    app.shutdown();
}
