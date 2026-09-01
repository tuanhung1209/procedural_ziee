const GlfwWindow = @import("glfw_window.zig").GlfwWindow;

const c = @import("glfw_window.zig").c;

pub const TreeApp = struct {
    window: GlfwWindow = .{},

    pub fn init(self: *TreeApp) bool {
        return self.window.init();
    }

    pub fn run(self: *TreeApp) void {
        while (!self.window.shouldClose()) {
            self.window.pollEvent();

            if (c.glfwGetKey(self.window.handle, c.GLFW_KEY_Q) == c.GLFW_PRESS) {
                c.glfwSetWindowShouldClose(self.window.handle, c.GLFW_TRUE);
            }

            // self.update, self.render here
        }
    }

    pub fn shutdown(self: *TreeApp) void {
        self.window.deinit();
    }
};
