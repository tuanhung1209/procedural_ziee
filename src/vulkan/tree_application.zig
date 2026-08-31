const GlfwWindow = @import("glfw_window.zig").GlfwWindow;

pub const TreeApp = struct {
    window: GlfwWindow = .{},

    pub fn init(self: *TreeApp) bool {
        return self.window.init();
    }

    pub fn run(self: *TreeApp) void {
        self.window.run();
    }

    pub fn shutdown(self: *TreeApp) void {
        self.window.deinit();
    }
};
