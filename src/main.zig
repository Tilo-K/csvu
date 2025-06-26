const std = @import("std");
const csv = @import("csv.zig");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = allocator.deinit();
    const alloc = allocator.allocator();

    var args = try std.process.ArgIterator.initWithAllocator(alloc);
    defer args.deinit();

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

    var file = try csv.loadFile(filepath, alloc);
    defer file.deinit();

    const valid = file.isValid();
    if (!valid) return;

    _ = try bw.flush();

    try csv.printTable(file);
    _ = try bw.flush();
}
