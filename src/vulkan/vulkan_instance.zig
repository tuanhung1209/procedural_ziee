const std = @import("std");
const c = @import("glfw_window.zig").c;

pub const VulkanInstance = struct {
    handle: ?c.VkInstance = null,
    allocator: std.mem.Allocator = undefined,
    extension_names: []const [*c]const u8 = &.{},

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

        var count: u32 = 0;
        const glfw_exts = c.glfwGetRequiredInstanceExtensions(&count);
        if (glfw_exts == null) return false;

        const exts = allocator.alloc([*c]const u8, count) catch return false;
        for (exts, glfw_exts[0..count]) |*e, ext| e.* = ext;
        self.extension_names = exts;

        const create_info = c.VkInstanceCreateInfo{
            .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            .pApplicationInfo = &self.app_info,
            .enabledExtensionCount = count,
            .ppEnabledExtensionNames = @ptrCast(exts.ptr),
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
        if (self.extension_names.len > 0) {
            self.allocator.free(self.extension_names);
            self.extension_names = &.{};
        }
    }
};
