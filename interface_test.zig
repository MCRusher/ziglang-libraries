const std = @import("std");
const warn = std.debug.warn;
const Allocator = std.mem.Allocator;
const Stream = std.io.OutStream(std.os.WriteError);

//showcases conventional method of implementing
//interfaces in zig as of 0.5.0

const Animal = struct {
    const Self = @This();
    const SpeakFn = fn(Self) []const u8;

    speakFn: SpeakFn,

    fn speak(self: Self) []const u8 {
        return self.speakFn(self);
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

    fn speak(animal: Animal) []const u8 {
        //can actually access state through animal
        // as long as is stored in memory and
        // animal arg is a pointer rather than value type:
        //const self = @fieldParentPtr(Dog,"animal",animal);
        //warn("{} says {}\n",self.name,"Woof!");
        return "Woof!";
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

    fn speak(animal: Animal) []const u8 {
        return "Meow!";
    }
};

fn speaker(stream: *Stream, animal: *const Animal) !void {
    try stream.print("{}\n",animal.speak());
}

pub fn main() !void {
    const allocator = std.heap.direct_allocator;

    var stdout = &(try std.io.getStdOut()).outStream().stream;
    //var stdout_state = (try std.io.getStdOut()).outStream();
    //var stdout = &stdout_state.stream;
    
    //without state, memory would leak.
    const dog_state = try Dog.init(allocator,"Jeff");
    defer dog_state.deinit();
    const dog = &dog_state.animal;
    const cat_state = try Cat.init(allocator,"Will");
    defer cat_state.deinit();
    const cat = &cat_state.animal;
    
    try speaker(stdout,dog);
    try speaker(stdout,cat);

    //vs

    const adog = try Dog.init(allocator,"Jeff");
    defer adog.deinit();
    const acat = try Cat.init(allocator,"Will");
    defer acat.deinit();
    try stdout.print("{} says {}\n",adog.name,adog.animal.speak());
    try stdout.print("{} says {}\n",acat.name,acat.animal.speak());
}
