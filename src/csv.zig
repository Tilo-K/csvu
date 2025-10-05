const std = @import("std");
const term = @import("term.zig");

const CsvError = error{
    NoDelimiterFound,
};

fn contains(arr: []const u8, target: u8) bool {
    for (arr) |element| {
        if (element == target) {
            return true;
        }
    }

    return false;
}

pub fn determineDelimiter(str: []const u8) !u8 {
    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = allocator.deinit();
    const alloc = allocator.allocator();

    const possibleDelimiter = [_]u8{ ',', ';', '\t', '|' };
    var countMap = std.AutoHashMap(u8, u32).init(alloc);
    defer countMap.deinit();

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
    alloc: std.mem.Allocator,

    pub fn isValid(self: CsvFile) bool {
        const colNum = self.header.items.len;
        for (self.entries.items) |entry| {
            if (entry.items.len != colNum) {
                return false;
            }
        }

        return true;
    }

    pub fn deinit(self: *CsvFile) void {
        for (self.header.items) |col| self.alloc.free(col);
        self.header.deinit(self.alloc);

        for (self.entries.items) |entry_c| {
            var entry = entry_c;
            for (entry.items) |col| self.alloc.free(col);
            entry.deinit(self.alloc);
        }
        self.entries.deinit(self.alloc);
    }
};

pub fn printTable(file: CsvFile) !void {
    var stdout_buf: [1024]u8 = undefined;
    const stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    var stdout = stdout_writer.interface;

    defer {
        _ = stdout.flush() catch null;
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
        col_sizes[i] = file.header.items[i].len + 1;
    }
    for (file.entries.items) |entry| {
        for (0..col_nums) |i| {
            const curr = col_sizes[i];
            if (entry.items[i].len + 1 > curr) {
                col_sizes[i] = entry.items[i].len + 1;
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
    _ = try stdout.flush();

    for (0..complete_length) |_| {
        try stdout.print("-", .{});
    }
    try stdout.print("\n", .{});

    for (file.entries.items) |entry| {
        var out_line = std.ArrayList(u8){};
        defer out_line.deinit(alloc);

        try out_line.appendSlice(alloc, "|");

        for (0..col_nums) |i| {
            const out = entry.items[i];
            const missing = col_sizes[i] - out.len;

            try out_line.appendSlice(alloc, out);

            for (0..missing) |_| {
                try out_line.appendSlice(alloc, " ");
            }
            try out_line.appendSlice(alloc, "|");
        }
        try out_line.appendSlice(alloc, "\n");

        _ = try stdout.writeAll(out_line.items);
        _ = try stdout.flush();
    }
    for (0..complete_length) |_| {
        try stdout.print("-", .{});
    }
    try stdout.print("\n", .{});
}

pub fn loadFile(filepath: []const u8, alloc: std.mem.Allocator) !CsvFile {
    var file_buf: [4096]u8 = undefined;

    var file = try std.fs.cwd().openFile(filepath, .{});
    defer file.close();
    var in_stream = file.reader(&file_buf).interface;

    var readHeader = false;
    var headerList: std.ArrayList([]const u8) = undefined;
    var entries = std.ArrayList(std.ArrayList([]const u8)){};
    var delimiter: u8 = ' ';

    while (true) {
        const line = in_stream.takeDelimiterExclusive('\n') catch |err| {
            if (err == error.EndOfStream) {
                break;
            }
            return err;
        };

        if (delimiter == ' ') {
            delimiter = try determineDelimiter(line);
        }

        const del = delimiter;
        var entr = std.ArrayList([]const u8){};
        var splitIt = std.mem.splitSequence(u8, line, &[_]u8{del});

        while (splitIt.next()) |part| {
            const dest = try alloc.alloc(u8, part.len);

            std.mem.copyForwards(u8, dest, part);
            const res = std.mem.trim(u8, dest, &[_]u8{ '\n', '\t', '\r', ' ' });

            const res2 = try alloc.alloc(u8, res.len);
            std.mem.copyForwards(u8, res2, res);
            alloc.free(dest);

            _ = try entr.append(alloc, res2);
        }

        if (!readHeader) {
            headerList = entr;
            readHeader = true;
            continue;
        }
        _ = try entries.append(alloc, entr);
    }

    return CsvFile{ .entries = entries, .header = headerList, .alloc = alloc };
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
