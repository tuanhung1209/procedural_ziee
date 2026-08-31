const c = @cImport({
    @cDefine("GLFW_INCLUDE_VULKAN", {});
    @cInclude("GLFW/glfw3.h");
});

pub const GlfwWindow = struct {
    handle: ?*c.GLFWwindow = null,
    width: i32 = 800,
    height: i32 = 600,

    pub fn init(self: *GlfwWindow) bool {
        if (c.glfwInit() == c.GLFW_FALSE) return false;

        c.glfwWindowHint(c.GLFW_CLIENT_API, c.GLFW_NO_API);
        self.handle = c.glfwCreateWindow(self.width, self.height, "Vulkan 1.3", null, null);
        if (self.handle == null) {
            c.glfwTerminate();
            return false;
        }
        return true;
    }

    pub fn run(self: *GlfwWindow) void {
        const window = self.handle orelse return;
        while (c.glfwWindowShouldClose(window) == c.GLFW_FALSE) {
            c.glfwPollEvents();
        }
    }

    pub fn deinit(self: *GlfwWindow) void {
        if (self.handle) |window| {
            c.glfwDestroyWindow(window);
            self.handle = null;
            c.glfwTerminate();
        }
    }

    pub fn changeResolution(self: *GlfwWindow, n_width: i32, n_height: i32) void {
        self.width = n_width;
        self.height = n_height;
        if (self.handle) |window| {
            c.glfwSetWindowSize(window, n_width, n_height);
        }
    }
};
