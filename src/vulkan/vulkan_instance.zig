const std = @import("std");
const c = @import("glfw_window.zig").c;

pub const VulkanInstance = struct {
    handle: ?c.VkInstance = null,
    allocator: std.mem.Allocator = undefined,
    extension_names: []const [*c]const u8 = &.{},

    // might not need this
    debug_messenger: c.VkDebugUtilsMessengerEXT,

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

        if (!self.collectExtensions()) return false;
        if (!self.createInstance()) {
            self.deinit();
            return false;
        }

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
        if (self.debug_messenger != null) {
            self.debug_messenger = null;
        }
    }

    // helper function bellow
    fn collectExtensions(self: *VulkanInstance) bool {
        var count: u32 = 0;
        const glfw_exts = c.glfwGetRequiredInstanceExtensions(&count);
        if (glfw_exts == null) return false;

        var exts: std.ArrayList([*c]const u8) = .empty;
        defer exts.deinit(self.allocator);

        //  might have to have argv for debug stuff
        exts.append(self.allocator, c.VK_EXT_DEBUG_UTILS_EXTENSION_NAME) catch return false;
        for (glfw_exts[0..count]) |ext| exts.append(self.allocator, ext) catch return false;

        for (exts.items) |ext| std.debug.print("{s}\n", .{ext});
        self.extension_names = exts.toOwnedSlice(self.allocator) catch return false;
        return true;
    }

    // TODO :
    fn debugCallback() bool {}

    fn createDebugLayer(self: *VulkanInstance) bool {
        const debug_info = c.VkDebugUtilsMessengerCreateInfoEXT{
            .sType = c.VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
            .messageSeverity = c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT | c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT,
            .messageType = c.VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | c.VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT,
            .pfnUserCallback = debugCallback,
        };

        var debug_messenger: c.VkDebugUtilsMessengerEXT = undefined;
        if (c.vkCreateDebugUtilsMessengerEXT(self.handle, &debug_info, null, &debug_messenger) != c.VK_SUCCESS) return false;
        self.debug_messenger = debug_messenger;
        return true;
    }

    fn createInstance(self: *VulkanInstance) bool {
        const create_info = c.VkInstanceCreateInfo{
            .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            .pApplicationInfo = &self.app_info,
            .enabledExtensionCount = @intCast(self.extension_names.len),
            .ppEnabledExtensionNames = @ptrCast(self.extension_names.ptr),
        };

        var instance: c.VkInstance = undefined;
        if (c.vkCreateInstance(&create_info, null, &instance) != c.VK_SUCCESS) return false;
        self.handle = instance;
        return true;
    }
};
