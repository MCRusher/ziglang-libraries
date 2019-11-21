const std = @import("std");

const DListError = error {
    EmptyListHasNoNodes,
};

pub fn DList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            item: T,
            next: ?*DList(T).Node,
            prev: ?*DList(T).Node,
        };
        
        allocator: *std.mem.Allocator,
        len: usize,
        first: ?*DList(T).Node,
        last: ?*DList(T).Node,
        
        pub fn init(allocator: *std.mem.Allocator) DList(T) {
            return DList(T){
                .allocator = allocator,
                .len = 0,
                .first = null,
                .last = null,
            };
        }
        pub fn push_first(self: *DList(T), item: T) !void {
            const node = try self.allocator.create(DList(T).Node);
            node.prev = null;
            node.next = self.first;
            node.item = item;
            //if first is null, list was empty and last needs set.
            if(self.first!=null)
                self.first.?.prev = node
            else self.last = node;
            self.first = node;
            self.len += 1;
        }
        pub fn push_last(self: *DList(T), item: T) !void {
            const node = try self.allocator.create(DList(T).Node);
            node.prev = self.last;
            node.next = null;
            node.item = item;
            //if last is null, list was empty and first needs set.
            if(self.last!=null)
                self.last.?.next = node
            else self.first = node;
            self.last = node;
            self.len += 1;
        }
        pub fn pop_first(self: *DList(T)) void {
            if(self.first!=null){
                const node = self.first.?;
                self.first = node.next;
                //if first is now null, list is now empty and last needs set to null.
                if(self.first!=null)
                    self.first.?.prev = null
                else self.last = null;
                self.allocator.destroy(node);
                self.len -= 1;
            }
        }
        pub fn pop_last(self: *DList(T)) void {
            if(self.last!=null){
                const node = self.last.?;
                self.last = node.prev;
                //if last is now null, list is now empty and first needs set to null.
                if(self.last!=null)
                    self.last.?.next = null
                else self.first = null;
                self.allocator.destroy(node);
                self.len -= 1;
            }
        }
        pub fn insert(self: *DList(T), link: *DList(T).Node, item: T) !*DList(T).Node {
            const node = try self.allocator.create(DList(T).Node);
            node.prev = link.prev;
            if(link.prev!=null)
                link.prev.?.next = node
            else{
                if(self.first==null)
                    self.last = node;
                self.first = node;
            }
            node.next = link;
            link.prev = node;
            node.item = item;
            self.len += 1;
            return node;
        }
        pub fn remove(self: *Dlist(T), link: *DList(T).Node) void {
            @panic("DList(T).remove() is not yet implemented.\n");
        }
        pub fn deinit(self: DList(T)) void {
            var prev: *DList(T).Node = undefined;
            var node = self.first;
            while(node!=null){
                prev = node.?;
                node = prev.next;
                self.allocator.destroy(prev);
            }
        }
        pub fn count(self: DList(T)) usize {
            return self.len;
        }
        pub fn firstNode(self: DList(T)) !*DList(T).Node {
            if(self.first==null)
                return DListError.EmptyListHasNoNodes;
            return self.first.?;
        }
        pub fn lastNode(self: DList(T)) !*DList(T).Node {
            if(self.last==null)
                return DListError.EmptyListHasNoNodes;
            return self.last.?;
        }
    };
}
