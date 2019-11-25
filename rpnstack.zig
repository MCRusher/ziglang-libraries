const std = @import("std");

pub fn RPNStack(comptime T: type) type {
    const DEFAULT_MAX = 20;
    return struct {
        allocator: *std.mem.Allocator,
        buf: []T,
        len: usize,

        pub fn init(allocator: *std.mem.Allocator) !RPNStack(T) {
            return RPNStack(T) {
                .allocator = allocator,
                .buf = try allocator.alloc(T,DEFAULT_MAX),
                .len = 0,
            };
        }
        pub fn deinit(self: RPNStack(T)) void {
            self.allocator.free(self.buf);
        }
        pub fn push(self: *RPNStack(T), item: T) *RPNStack(T) {
            if(self.len==self.buf.len){
                self.len *= 2;
                self.buf = self.allocator.realloc(self.buf,self.len) catch {
                    @panic("Could not push to RPNStack");
                };
            }
            self.buf[self.len] = item;
            self.len += 1;
            return self;
        }
        pub fn pop(self: *RPNStack(T)) T {
            if(self.buf.len==0)
                @panic("Cannot pop from empty RPNStack");
            const item = self.buf[self.len-1];
            self.len -= 1;
            return item;
        }
        pub fn add(self: *RPNStack(T)) *RPNStack(T) {
            if(self.len<2)
                @panic("Cannot add with less than 2 stack slots");
            const res = self.buf[self.len-2] + self.buf[self.len-1];
            self.len -= 1;
            self.buf[self.len-1] = res;
            return self;
        }
        pub fn sub(self: *RPNStack(T)) *RPNStack(T) {
            if(self.len<2)
                @panic("Cannot subtract with less than 2 stack slots");
            const res = self.buf[self.len-2] - self.buf[self.len-1];
            self.len -= 1;
            self.buf[self.len-1] = res;
            return self;
        }
        pub fn mul(self: *RPNStack(T)) *RPNStack(T) {
            if(self.len<2)
                @panic("Cannot multiply with less than 2 stack slots");
            const res = self.buf[self.len-2] * self.buf[self.len-1];
            self.len -= 1;
            self.buf[self.len-1] = res;
            return self;
        }
        pub fn div(self: *RPNStack(T)) *RPNStack(T) {
            if(self.len<2)
                @panic("Cannot divide with less than 2 stack slots");
            const res = self.buf[self.len-2] / self.buf[self.len-1];
            self.len -= 1;
            self.buf[self.len-1] = res;
            return self;
        }
        pub fn mod(self: *RPNStack(T)) *RPNStack(T) {
            if(self.len<2)
                @panic("Cannot modulus with less than 2 stack slots");
            const res = self.buf[self.len-2] % self.buf[self.len-1];
            self.len -= 1;
            self.buf[self.len-1] = res;
            return self;
        }
        pub fn neg(self: *RPNStack(T)) *RPNStack(T) {
            if(self.len<1)
                @panic("Cannot negate with less than 1 stack slot");
            const res = -self.buf[self.len-1];
            self.buf[self.len-1] = res;
            return self;
        }
    };
}