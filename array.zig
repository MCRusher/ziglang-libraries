const std = @import("std");

const assert = std.debug.assert;

pub const ArrayError = error {
    OutOfBounds,
};

pub fn Array(comptime T: type) type {
    return struct {

        const Self = @This();

        arr: []T,
        allocator: *std.mem.Allocator,

        pub fn init(allocator: *std.mem.Allocator) Self {
            return Self {
                .arr = [_]T{},
                .allocator = allocator,
            };
        }

        pub fn initNew(allocator: *std.mem.Allocator, count: usize) !Self {
            return Self {
                .arr = try allocator.alloc(T,count),
                .allocator = allocator,
            };
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.arr);
        }

        pub fn fromOwnedSlice(allocator: *std.mem.Allocator, slice: []T) Self {
            return Self {
                .arr = slice,
                .allocator = allocator,
            };
        }

        pub fn toOwnedSlice(self: *Self) []T {
            const arr = self.arr;
            self.arr = [_]T{};
            return arr;
        }

        pub fn toSlice(self: Self, start_pos: usize, count: usize) []T {
            if(start_pos >= self.arr.len or start_pos+count-1 >= self.arr.len)
                @panic("Array.toSlice() range is out of bounds");
            return self.arr[start_pos..start_pos+count];
        }

        pub fn toSliceConst(self: Self, start_pos: usize, count: usize) []const T {
            if(start_pos >= self.arr.len or start_pos+count-1 >= self.arr.len)
                @panic("Array.toSliceConst() range is out of bounds");
            return self.arr[start_pos..start_pos+count];
        }

        pub fn at(self: Self, pos: usize) T {
            assert(pos < self.arr.len);
            return self.arr[pos];
        }

        pub fn safeAt(self: Self, pos: usize) !T {
            if(pos>=self.arr.len)
                return ArrayError.OutOfBounds;
            return self.arr[pos];
        }

        pub fn set(self: Self, pos: usize, item: T) void {
            assert(pos < self.arr.len);
            self.arr[pos] = item;
        }

        pub fn safeSet(self: Self, pos: usize, item: T) !void {
            if(pos >= self.arr.len)
                return ArrayError.OutOfBounds;
            self.arr[pos] = item;
        }

        pub fn len(self: Self) usize {
            return self.arr.len;
        }

        pub fn clone(self: Self) !Self {
            const tmp = try self.allocator.alloc(T,self.arr.len);
            return Self {
                .arr = std.mem.copy(T,tmp,self.arr),
                .allocator = self.allocator,
            };
        }

        pub fn filter(self: Self, predicate: fn(T)bool) !Self {
            var arr = try self.allocator.alloc(T,self.arr.len);
            var count: usize = 0;
            for(self.arr) |item| {
                if(predicate(item)){
                    arr[count] = item;
                    count += 1;
                }
            }
            return Self {
                .arr = try self.allocator.realloc(arr,count),
                .allocator = self.allocator,
            };
        }

        pub fn map(self: Self, comptime X: type, mapper: fn(T)X) !Array(X) {
            var arr = try self.allocator.alloc(X,self.arr.len);
            for(self.arr) |item,i| {
                arr[i] = mapper(item);
            }
            return Array(X) {
                .arr = arr,
                .allocator = self.allocator,
            };
        }

        pub fn reduce(self: Self, comptime X: type, reducer: var, initial: X) X {
            var accumulator = initial;
            for(self.arr) |item| {
                accumulator = reducer(accumulator,item);
            }
            return accumulator;
        }
    };
}