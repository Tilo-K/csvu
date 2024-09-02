const std = @import("std");
const builtin = @import("builtin");

const Dimensions = struct { width: u16, height: u16 };

const Error = error{ UnsupportedOs, ErrorFetchingDimensions };

pub fn getTerminalDimensions() !Dimensions {
    const os_tag = builtin.os.tag;

    switch (os_tag) {
        .linux, .macos, .freebsd, .openbsd, .netbsd => {
            return try getUnixTerminalDimensions();
        },
        .windows => {
            return try getWindowsTerminalDimensions();
        },
        else => {
            return Error.UnsupportedOs;
        }
    }
}

fn getUnixTerminalDimensions() !Dimensions {
    const os = std.os;

    const size: os.linux.winsize = undefined;
    const fd = std.io.getStdOut().handle;

    _ = os.linux.ioctl(fd, os.linux.T.IOCSWINSZ, @intFromPtr(&size));

    return Dimensions{ .width = size.ws_col, .height = size.ws_row };
}

fn getWindowsTerminalDimensions() !Dimensions {
    const win = std.os.windows;
    const handle = win.GetStdHandle(win.STD_OUTPUT_HANDLE) catch return Error.ErrorFetchingDimensions;

    var csbi: win.CONSOLE_SCREEN_BUFFER_INFO = undefined;

    if (win.kernel32.GetConsoleScreenBufferInfo(handle, &csbi) == 0) {
        return Error.ErrorFetchingDimensions;
    }

    const width = csbi.srWindow.Right - csbi.srWindow.Left + 1;
    const height = csbi.srWindow.Bottom - csbi.srWindow.Top + 1;

    return Dimensions{
        .width = @intCast(width),
        .height = @intCast(height),
    };
}
