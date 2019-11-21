const std = @import("std");

pub const VectorError = error{
    OutOfBounds,
    ZeroMaxCountIsUngrowable,
};

pub fn Vector(comptime T: type) type {
    const DEFAULT_MAX = 20;
    return struct {
        arr: []T,
        allocator: *std.mem.Allocator,
        len: usize,
        
        pub fn initSize(allocator: *std.mem.Allocator, init_max: usize) !Vector(T) {
            return Vector(T){
                .arr = try allocator.alloc(T,init_max),
                .allocator = allocator,
                .len = 0,
            };
        }
        //NOTE: 0*2 = 0, so push would need an additional check for when arr.len==0, and then allocate the array
        //pub fn initEmpty(allocator: *std.mem.Allocator) Vector(T) {
        //    return Vector(T){
        //        .arr = [_]T{},
        //        .allocator = allocator,
        //        .len = 0,
        //    };
        //}
        pub fn init(allocator: *std.mem.Allocator) !Vector(T) {
            return Vector(T){
                .arr = try allocator.alloc(T,DEFAULT_MAX),
                .allocator = allocator,
                .len = 0,
            };
        }
        pub fn deinit(self: *Vector(T)) void {
            self.allocator.free(self.arr);
        }
        pub fn push(self: *Vector(T), item: T) !void {
            if(self.len==self.arr.len){
                const new_max = self.arr.len*2;
                self.arr = try self.allocator.realloc(self.arr,new_max);
            }
            self.arr[self.len] = item;
            self.len += 1;
        }
        pub fn pop(self: *Vector(T)) void {
            if(self.len!=0){
                self.len -= 1;
            }
        }
        pub fn shrinkToCount(self: *Vector(T)) !void {
            if(self.len==0)
                return VectorError.ZeroMaxCountIsUngrowable;
            self.arr = try self.allocator.realloc(self.arr,self.len);
        }
        pub fn count(self: Vector(T)) usize {
            return self.len;
        }
        pub fn maxCount(self: Vector(T)) usize {
            return self.arr.len;
        }
        pub fn at(self: Vector(T), index: usize) T {
            return self.arr[index];
        }
        pub fn safeAt(self: Vector(T), index: usize) !T {
            if(index>=self.len)
                return VectorError.OutOfBounds;
            return self.arr[index];
        }
    };
}