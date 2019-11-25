const std = @import("std");

const RPNStack = @import("rpnstack.zig").RPNStack;

pub fn main() !void {
    var rpn = try RPNStack(i64).init(std.heap.direct_allocator);
    defer rpn.deinit();
    const res = rpn.push(1).push(2).add().push(5).mul().pop();
    std.debug.warn("res: {}\n",res);
}