const std = @import("std");

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
    const possibleDelimiter = []u8{ ',', ';', '\t', '|' };
    var countMap = std.AutoHashMap(u8, u32);

    for (possibleDelimiter) |del| {
        countMap.put(del, 0);
    }

    for (str) |c| {
        if (!contains(possibleDelimiter, c)) {
            continue;
        }

        const current = countMap.get(c);
        countMap.put(c, current + 1);
    }

    var currDel: u8 = ' ';
    var highest: u32 = 0;

    for (countMap.keyIterator()) |key| {
        const val = try countMap.get(key);
        if (val > highest) {
            currDel = key;
            highest = val;
        }
    }

    if (currDel == ' ') {
        return CsvError.NoDelimiterFound;
    }

    return currDel;
}

pub fn loadFile(filepath: []const u8) !void {
    const alloc = std.heap.page_allocator;
    var file = try std.fs.cwd().openFile(filepath, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buffer: [4096]u8 = undefined;

    var readHeader = false;
    var headerList = undefined;
    var entries = std.ArrayList(std.ArrayList([]const u8)).init(alloc);
    var delimiter = ' ';

    while (try in_stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if (delimiter == ' ') {
            delimiter = determineDelimiter(line);
        }

        var entr = std.ArrayList([]const u8).init(alloc);
        const splitIt = std.mem.split(u8, line, delimiter);
        for (splitIt) |part| {
            _ = try entr.append(part);
        }

        if (!readHeader) {
            headerList = entr;
            readHeader = true;
            continue;
        }
        _ = try entries.append(entr);
    }
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
