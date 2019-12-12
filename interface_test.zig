const std = @import("std");
const warn = std.debug.warn;
const Allocator = std.mem.Allocator;
const Stream = std.io.OutStream(std.os.WriteError);

//showcases conventional method of implementing
//interfaces in zig as of 0.5.0

const Animal = struct {
    const Self = @This();
    const SpeakFn = fn(*const Self, *Stream) void;

    speakFn: SpeakFn,

    fn speak(self: *const Self, stream: *Stream) void {
        return self.speakFn(self,stream);
    }
};

const Dog = struct {
    const Self = @This();

    animal: Animal,
    name: []const u8,
    allocator: *Allocator,

    fn init(allocator: *Allocator, name: []const u8) !Self {
        const animal = Animal {
            .speakFn = speak,
        };
        const buf = try allocator.alloc(u8,name.len);
        std.mem.copy(u8,buf,name);
        return Self {
            .animal = animal,
            .name = buf,
            .allocator = allocator,
        };
    }

    fn deinit(self: Self) void {
        self.allocator.free(self.name);
    }

    fn speak(animal: *const Animal, stream: *Stream) void {
        const self = @fieldParentPtr(Self,"animal",animal);
        stream.print("{} says {}\n",self.name,"Woof!") catch {};
    }
};

const Cat = struct {
    const Self = @This();

    animal: Animal,
    name: []const u8,
    allocator: *Allocator,

    fn init(allocator: *Allocator, name: []const u8) !Self {
        const animal = Animal {
            .speakFn = speak,
        };
        const buf = try allocator.alloc(u8,name.len);
        std.mem.copy(u8,buf,name);
        return Self {
            .animal = animal,
            .name = buf,
            .allocator = allocator,
        };
    }

    fn deinit(self: Self ) void {
        self.allocator.free(self.name);
    }

    fn speak(animal: *const Animal, stream: *Stream) void {
        const self = @fieldParentPtr(Self,"animal",animal);
        stream.print("{} says {}\n",self.name,"Meow!") catch {};
    }
};

pub fn main() !void {
    const allocator = std.heap.direct_allocator;

    var stdout = &(try std.io.getStdOut()).outStream().stream;
    //var stdout_state = (try std.io.getStdOut()).outStream();
    //var stdout = &stdout_state.stream;
    
    const dog_state = try Dog.init(allocator,"Jeff");
    defer dog_state.deinit();
    const dog = &dog_state.animal;
    const cat_state = try Cat.init(allocator,"Will");
    defer cat_state.deinit();
    const cat = &cat_state.animal;


    dog.speak(stdout);
    cat.speak(stdout);
}
