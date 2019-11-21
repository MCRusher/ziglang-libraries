const std = @import("std");
const Point = @import("vector.zig").Point;
const Vector = @import("vector.zig").Vector;

pub fn main() !void {
    var vec = Vector(i32).init(std.heap.direct_allocator)
              catch @panic("Could not preallocate vector.\n");
    defer vec.deinit();
    try vec.push(12);
    try vec.shrinkToCount();
    try vec.push(6);
    try vec.push(7);
    //vec.pop();
    std.debug.warn("len: {}, max: {}, vec[0]: {}\n",vec.count(),vec.maxCount(),try vec.safeAt(0));
}