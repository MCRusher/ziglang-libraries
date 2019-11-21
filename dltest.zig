const std = @import("std");
const DList = @import("dllist.zig").DList;

pub fn main() !void {
    var list = DList(i32).init(std.heap.direct_allocator);
    defer list.deinit();
    try list.push_last(1);
    try list.push_last(2);
    try list.push_last(3);
    try list.push_last(4);
    var i: usize = 0;
    var iter: @typeOf(list.first) = list.first;
    while(iter!=null){
        std.debug.warn("iter.item: {}\n",iter.?.item);
        iter = iter.?.next;
    }
    var node = try list.insert(try list.firstNode(),0);
    iter = node;
    while(iter!=null){
        std.debug.warn("iter.item: {}\n",iter.?.item);
        iter = iter.?.next;
    }
}