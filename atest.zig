const std = @import("std");

const Array = @import("array.zig").Array;

fn pred(val: i32) bool {
    return @mod(val,2) == 0;
}

fn mapper(val: i32) i32 {
    return val + 1;
}

fn reducer(accum: i64, item: i32) i64 {
    return accum + item;
}

pub fn main() !void {
    var arr = try Array(i32).initNew(std.heap.direct_allocator,4);
    defer arr.deinit();
    arr.set(0,1);
    arr.set(1,2);
    arr.set(2,3);
    arr.set(3,4);
    std.debug.warn("arr:\n");
    for(arr.toSliceConst(0,arr.len())) |i| {
        std.debug.warn("{}\n",i);
    }
    var even = try arr.filter(pred);
    defer even.deinit();
    std.debug.warn("even:\n");
    for(even.toSliceConst(0,even.len())) |i| {
        std.debug.warn("{}\n",i);
    }
    var plus_one = try arr.map(i32,mapper);
    defer plus_one.deinit();
    std.debug.warn("plus_one:\n");
    for(plus_one.toSliceConst(0,plus_one.len())) |i| {
        std.debug.warn("{}\n",i);
    }
    const sum = arr.reduce(i64,reducer,0);
    std.debug.warn("arr sum: {}\n",sum);
}