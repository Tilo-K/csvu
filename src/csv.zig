const std = @import("std");
const term = @import("term.zig");

const CsvError = error{
    NoDelimiterFound,
};

fn concat(one: []const u8, two: []const u8) ![]const u8 {
    const allocator = std.heap.page_allocator;
    var result = try allocator.alloc(u8, one.len + two.len);

    std.mem.copyForwards(u8, result[0..], one);
    std.mem.copyForwards(u8, result[one.len..], two);

    return result;
}

fn contains(arr: []const u8, target: u8) bool {
    for (arr) |element| {
        if (element == target) {
            return true;
        }
    }

    return false;
}

pub fn determineDelimiter(str: []const u8) !u8 {
    const alloc = std.heap.page_allocator;

    const possibleDelimiter = [_]u8{ ',', ';', '\t', '|' };
    var countMap = std.AutoHashMap(u8, u32).init(alloc);

    for (possibleDelimiter) |del| {
        try countMap.put(del, 0);
    }

    for (str) |c| {
        if (!contains(&possibleDelimiter, c)) {
            continue;
        }

        const current = countMap.get(c) orelse 0;
        try countMap.put(c, current + 1);
    }

    var currDel: u8 = ' ';
    var highest: u32 = 0;

    var iter = countMap.keyIterator();
    while (iter.next()) |key| {
        const val = countMap.get(key.*) orelse 0;
        if (val > highest) {
            currDel = key.*;
            highest = val;
        }
    }

    if (currDel == ' ') {
        return CsvError.NoDelimiterFound;
    }

    return currDel;
}

const CsvFile = struct {
    header: std.ArrayList([]const u8),
    entries: std.ArrayList(std.ArrayList([]const u8)),

    pub fn isValid(self: CsvFile) bool {
        const colNum = self.header.items.len;
        for (self.entries.items) |entry| {
            if (entry.items.len != colNum) {
                return false;
            }
        }

        return true;
    }
};

pub fn printTable(file: CsvFile) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    defer {
        _ = bw.flush() catch null;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }

    const alloc = gpa.allocator();
    const dimensions = try term.getTerminalDimensions();
    const col_nums = file.header.items.len;
    const col_sizes = try alloc.alloc(usize, col_nums);
    defer alloc.free(col_sizes);

    for (0..col_nums) |i| {
        col_sizes[i] = file.header.items[i].len;
    }
    for (file.entries.items) |entry| {
        for (0..col_nums) |i| {
            const curr = col_sizes[i];
            if (entry.items[i].len > curr) {
                col_sizes[i] = entry.items[i].len;
            }
        }
    }

    _ = dimensions;

    var complete_length = col_nums + 1;
    for (col_sizes) |col_size| {
        complete_length += col_size;
    }

    for (0..complete_length) |_| {
        try stdout.print("-", .{});
    }
    try stdout.print("\n|", .{});

    for (0..col_nums) |i| {
        const out = file.header.items[i];
        const missing = col_sizes[i] - out.len;

        _ = try stdout.writeAll(out);

        for (0..missing) |_| {
            _ = try stdout.writeAll(" ");
        }
        _ = try stdout.writeAll("|");
    }

    _ = try stdout.writeAll("\n");
    _ = try bw.flush();

    for (0..complete_length) |_| {
        try stdout.print("-", .{});
    }
    try stdout.print("\n", .{});

    for (file.entries.items) |entry| {
        var out_line: []const u8 = "|";

        for (0..col_nums) |i| {
            const out = entry.items[i];
            const missing = col_sizes[i] - out.len;

            out_line = try concat(out_line, out);

            for (0..missing) |_| {
                out_line = try concat(out_line, " ");
            }
            out_line = try concat(out_line, "|");
        }
        out_line = try concat(out_line, "\n");
        _ = try stdout.writeAll(out_line);
        _ = try bw.flush();
    }
    for (0..complete_length) |_| {
        try stdout.print("-", .{});
    }
    try stdout.print("\n", .{});
}

pub fn loadFile(filepath: []const u8) !CsvFile {
    const alloc = std.heap.page_allocator;
    var file = try std.fs.cwd().openFile(filepath, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buffer: [4096]u8 = undefined;

    var readHeader = false;
    var headerList: std.ArrayList([]const u8) = undefined;
    var entries = std.ArrayList(std.ArrayList([]const u8)).init(alloc);
    var delimiter: u8 = ' ';

    while (try in_stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if (delimiter == ' ') {
            delimiter = try determineDelimiter(line);
        }

        const del = delimiter;
        var entr = std.ArrayList([]const u8).init(alloc);
        var splitIt = std.mem.splitSequence(u8, line, &[_]u8{del});

        while (splitIt.next()) |part| {
            const dest = try alloc.alloc(u8, part.len);

            std.mem.copyForwards(u8, dest, part);
            const res = std.mem.trim(u8, dest, &[_]u8{ '\n', '\t', '\r', ' ' });
            _ = try entr.append(res);
        }

        if (!readHeader) {
            headerList = entr;
            readHeader = true;
            continue;
        }
        _ = try entries.append(entr);
    }

    return CsvFile{ .entries = entries, .header = headerList };
}

test "Determine delimiter" {
    const del = try determineDelimiter("this,is,a,test");
    std.testing.expect(del == ',');

    const del2 = try determineDelimiter("th#is; is,a; test;     with,many;symbols");
    std.testing.expect(del2 == ';');

    determineDelimiter("This does not have an delimiter") catch |err| {
        try std.testing.expect(err == CsvError.NoDelimiterFound);
    };
}
