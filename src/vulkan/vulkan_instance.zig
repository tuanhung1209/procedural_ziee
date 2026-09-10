const std = @import("std");
const c = @import("glfw_window.zig").c;

const GlfwWindow = @import("glfw_window.zig").GlfwWindow;

const enable_validation = true;
const validation_layers = [_][*c]const u8{"VK_LAYER_KHRONOS_validation"};

pub const VulkanInstance = struct {
    const Self = @This();

    handle: ?c.VkInstance = null,

    allocator: std.mem.Allocator = undefined,
    extension_names: []const [*c]const u8 = &.{},
    debug_messenger: c.VkDebugUtilsMessengerEXT = null,
    physical_device: c.VkPhysicalDevice = null,

    vulkan_surface: c.VkSurfaceKHR = null,

    app_info: c.VkApplicationInfo = .{
        .sType = c.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = "Procedural Ziee",
        .applicationVersion = c.VK_MAKE_VERSION(0, 1, 0),
        .pEngineName = "No Engine",
        .engineVersion = c.VK_MAKE_VERSION(0, 1, 0),
        .apiVersion = c.VK_API_VERSION_1_3,
    },

    pub fn init(self: *Self, allocator: std.mem.Allocator) bool {
        self.allocator = allocator;

        if (!self.collectExtensions()) return false;
        if (!self.createInstance()) {
            self.deinit();
            return false;
        }
        if (!self.createDebugMessenger()) {
            self.deinit();
            return false;
        }

        if (!self.findPhysicalDevices()) {
            self.deinit();
            return false;
        }

        return true;
    }

    pub fn deinit(self: *Self) void {
        if (self.handle) |instance| {
            if (self.debug_messenger) |messenger| {
                const proc = c.glfwGetInstanceProcAddress(instance, "vkDestroyDebugUtilsMessengerEXT");
                if (proc) |p| {
                    const destroy_fn: c.PFN_vkDestroyDebugUtilsMessengerEXT = @ptrCast(p);
                    destroy_fn.?(instance, messenger, null);
                }
                self.debug_messenger = null;
            }

            if (self.physical_device) |_| {
                self.physical_device = null;
            }

            if (self.vulkan_surface) |surface| {
                c.vkDestroySurfaceKHR(instance, surface, null);
                self.vulkan_surface = null;
            }
            c.vkDestroyInstance(instance, null);
            self.handle = null;
        }

        if (self.extension_names.len > 0) {
            self.allocator.free(self.extension_names);
            self.extension_names = &.{};
        }
    }

    // public function
    pub fn createVulkanSurface(self: *Self, glfwWindow: *GlfwWindow) bool {
        var vulkan_surface: c.VkSurfaceKHR = null;
        const handle: c.VkInstance = self.handle orelse return false;
        if (c.glfwCreateWindowSurface(handle, glfwWindow.handle, null, &vulkan_surface) != c.VK_SUCCESS) {
            return false;
        }
        self.vulkan_surface = vulkan_surface;
        return true;
    }

    // hepler function
    fn collectExtensions(self: *Self) bool {
        var count: u32 = 0;
        const glfw_exts = c.glfwGetRequiredInstanceExtensions(&count);
        if (glfw_exts == null) return false;

        const total = count + @as(u32, if (enable_validation) 1 else 0);
        const exts = self.allocator.alloc([*c]const u8, total) catch return false;
        for (exts[0..count], glfw_exts[0..count]) |*e, ext| e.* = ext;
        if (enable_validation) exts[count] = c.VK_EXT_DEBUG_UTILS_EXTENSION_NAME;
        self.extension_names = exts;
        return true;
    }

    fn createInstance(self: *Self) bool {
        var debug_info: c.VkDebugUtilsMessengerCreateInfoEXT = undefined;
        var layer_count: u32 = 0;
        var layer_names: [*c]const [*c]const u8 = null;

        if (enable_validation) {
            debug_info = self.debugCreateInfo();
            layer_count = validation_layers.len;
            layer_names = &validation_layers;
        }

        const create_info = c.VkInstanceCreateInfo{
            .sType = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            .pApplicationInfo = &self.app_info,
            .pNext = if (enable_validation) @ptrCast(&debug_info) else null,
            .enabledLayerCount = layer_count,
            .ppEnabledLayerNames = layer_names,
            .enabledExtensionCount = @intCast(self.extension_names.len),
            .ppEnabledExtensionNames = @ptrCast(self.extension_names.ptr),
        };

        var instance: c.VkInstance = null;
        if (c.vkCreateInstance(&create_info, null, &instance) != c.VK_SUCCESS) return false;
        self.handle = instance;
        return true;
    }

    fn createDebugMessenger(self: *Self) bool {
        const instance = self.handle orelse return false;

        const proc = c.glfwGetInstanceProcAddress(instance, "vkCreateDebugUtilsMessengerEXT");
        if (proc == null) return false;
        const create_fn: c.PFN_vkCreateDebugUtilsMessengerEXT = @ptrCast(proc);

        const info = self.debugCreateInfo();
        var messenger: c.VkDebugUtilsMessengerEXT = null;
        if (create_fn.?(instance, &info, null, &messenger) != c.VK_SUCCESS) return false;
        self.debug_messenger = messenger;
        return true;
    }

    fn debugCreateInfo(self: *Self) c.VkDebugUtilsMessengerCreateInfoEXT {
        _ = self;
        return .{
            .sType = c.VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
            .messageSeverity = c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT |
                c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT,
            .messageType = c.VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT |
                c.VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT |
                c.VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT,
            .pfnUserCallback = debugCallback,
        };
    }

    fn findPhysicalDevices(self: *Self) bool {
        var count: u32 = 0;
        const handle: c.VkInstance = self.handle orelse return false;
        if (c.vkEnumeratePhysicalDevices(handle, &count, null) != c.VK_SUCCESS) return false;
        const devices = self.allocator.alloc(c.VkPhysicalDevice, count) catch return false;
        if (c.vkEnumeratePhysicalDevices(handle, &count, devices.ptr) != c.VK_SUCCESS) return false;

        var chosen_device: c.VkPhysicalDevice = null;

        chosen_device = devices[0];
        for (devices) |device| {
            var prop: c.VkPhysicalDeviceProperties = .{};
            c.vkGetPhysicalDeviceProperties(device, &prop);
            if (prop.deviceType == c.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU) {
                chosen_device = device;
                break;
            }
        }

        self.allocator.free(devices);
        self.physical_device = chosen_device;
        return true;
    }
};

fn debugCallback(
    severity: c.VkDebugUtilsMessageSeverityFlagBitsEXT,
    _: c.VkDebugUtilsMessageTypeFlagsEXT,
    callback_data: [*c]const c.VkDebugUtilsMessengerCallbackDataEXT,
    _: ?*anyopaque,
) callconv(.c) c.VkBool32 {
    if (severity >= c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT) {
        std.debug.print("[vulkan] {s}\n", .{std.mem.span(callback_data.*.pMessage)});
    }
    return c.VK_FALSE;
}
