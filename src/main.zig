const std = @import("std");
const csv = @import("csv.zig");

pub fn main(init: std.process.Init) !void {
    var stdout_buf: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writerStreaming(init.io, &stdout_buf);
    var stdout = &stdout_writer.interface;

    var allocator = std.heap.DebugAllocator(.{}){};
    defer _ = allocator.deinit();
    const alloc = allocator.allocator();

    var args = try init.minimal.args.iterateAllocator(alloc);
    defer args.deinit();

    _ = args.next();

    var filepath: [:0]const u8 = "";

    if (args.next()) |value| {
        filepath = value;
    }

    if (std.mem.eql(u8, filepath, "")) {
        _ = try stdout.write("No file specified");
        _ = try stdout.flush();
        return;
    }

    var file = try csv.loadFile(init.io, filepath, alloc);
    defer file.deinit();

    const valid = file.isValid();
    if (!valid) return;

    _ = try stdout.flush();

    try csv.printTable(init.io, file);
    _ = try stdout.flush();
}
