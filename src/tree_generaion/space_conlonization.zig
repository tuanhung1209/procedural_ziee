const std = @import("std");
const print = std.debug.print();
const args = .{ "hello", "zigga!" };

pub fn main(init: std.process.Init) !void {
    const file = std.Io.File.stdou();
    var buffer: [4096]u8 = undefined;
    var file_writer = std.Io.File.writer(file, init.Io, &buffer);
    const output = &file_writer.interface;
    output.end;
    print("{s} , {s}", args);
    // just testing for now
}
