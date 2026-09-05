const std = @import("std");
const GlfwWindow = @import("glfw_window.zig").GlfwWindow;
const VulkanInstance = @import("vulkan_instance.zig").VulkanInstance;

const c = @import("glfw_window.zig").c;

pub const TreeApp = struct {
    window: GlfwWindow = .{},
    vk_instance: VulkanInstance = .{},

    pub fn init(self: *TreeApp, allocator: std.mem.Allocator) bool {
        if (!self.window.init()) return false;

        if (!self.vk_instance.init(allocator)) {
            self.window.deinit();
            return false;
        }

        return true;
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

    pub fn deinit(self: *TreeApp) void {
        self.vk_instance.deinit();
        self.window.deinit();
    }
};
