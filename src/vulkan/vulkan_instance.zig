const std = @import("std");
const c = @import("glfw_window.zig").c;

pub const VulkanInstance = struct {
    handle: ?c.VkInstance = null,
    allocator: std.mem.Allocator = undefined,

    app_info: c.VkApplicationInfo = .{
        .sType = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = "Procedural Ziee",
        .applicationVersion = c.VK_MAKE_VERSION(0, 1, 0),
        .pEngineName = "No Engine",
        .engineVersion = c.VK_MAKE_VERSION(0, 1, 0),
        .apiVersion = c.VK_API_VERSION_1_3,
    },

    pub fn init(self: *VulkanInstance, allocator: std.mem.Allocator) bool {
        self.allocator = allocator;

        const create_info = c.VkInstanceCreateInfo{
            .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            .pApplicationInfo = &self.app_info,
        };

        var instance: c.VkInstance = null;
        if (c.vkCreateInstance(&create_info, null, &instance) != c.VK_SUCCESS) return false;
        self.handle = instance;
        return true;
    }

    pub fn deinit(self: *VulkanInstance) void {
        if (self.handle) |instance| {
            c.vkDestroyInstance(instance, null);
            self.handle = null;
        }
    }
};
