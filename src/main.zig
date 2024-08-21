const std = @import("std");
const csv = @import("csv.zig");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    const alloc = std.heap.page_allocator;

    var args = try std.process.ArgIterator.initWithAllocator(alloc);
    _ = args.next();

    var filepath: [:0]const u8 = "";

    if (args.next()) |value| {
        filepath = value;
    }

    if (std.mem.eql(u8, filepath, "")) {
        _ = try stdout.write("No file specified");
        _ = try bw.flush();
        return;
    }

    try csv.loadFile(filepath);

    _ = try bw.flush();
}
