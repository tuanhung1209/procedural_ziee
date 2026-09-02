const c = @import("glfw_window.zig").c;

pub const VulkanInstance = struct {
    handle: ?c.VkInstance = null,

    app_info: c.VkApplicationInfo = .{
        .sType = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = "Procedural Ziee",
        .applicationVersion = c.VK_MAKE_VERSION(0, 1, 0),
        .pEngineName = "No Engine",
        .engineVersion = c.VK_MAKE_VERSION(0, 1, 0),
        .apiVersion = c.VK_API_VERSION_1_3,
    },

    pub fn init(self: *VulkanInstance) bool {
        // Only VkApplicationInfo is populated for now.
        // VkInstanceCreateInfo / vkCreateInstance come later.
        _ = self;
        return true;
    }

    pub fn deinit(self: *VulkanInstance) void {
        _ = self;
    }
};
