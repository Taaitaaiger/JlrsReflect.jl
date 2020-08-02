struct BitsTypeBool
    a::Bool
end

struct BitsTypeChar
    a::Char
end

struct BitsTypeUInt8
    a::UInt8
end

struct BitsTypeUInt16
    a::UInt16
end

struct BitsTypeUInt32
    a::UInt32
end

struct BitsTypeUInt64
    a::UInt64
end

struct BitsTypeUInt
    a::UInt
end

struct BitsTypeInt8
    a::Int8
end

struct BitsTypeInt16
    a::Int16
end

struct BitsTypeInt32
    a::Int32
end

struct BitsTypeInt64
    a::Int64
end

struct BitsTypeInt
    a::Int
end

struct BitsTypeFloat32
    a::Float32
end

struct BitsTypeFloat64
    a::Float64
end

@testset "Single-field bits types" begin
    @test begin
        b = JlrsReflect.reflect([BitsTypeBool])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeBool] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeBool")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsTypeBool {
            a: bool,
        }"""
    end
        
    @test begin
        b = JlrsReflect.reflect([BitsTypeChar])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeChar] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeChar")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsTypeChar {
            a: char,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt8])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeUInt8] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeUInt8")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsTypeUInt8 {
            a: u8,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt16])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeUInt16] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeUInt16")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsTypeUInt16 {
            a: u16,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt32])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeUInt32] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeUInt32")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsTypeUInt32 {
            a: u32,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt64])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeUInt64] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeUInt64")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsTypeUInt64 {
            a: u64,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeUInt] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeUInt")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsTypeUInt {
            a: u64,
        }"""
    end    

    @test begin
        b = JlrsReflect.reflect([BitsTypeInt8])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeInt8] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeInt8")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsTypeInt8 {
            a: i8,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeInt16])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeInt16] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeInt16")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsTypeInt16 {
            a: i16,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeInt32])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeInt32] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeInt32")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsTypeInt32 {
            a: i32,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeInt64])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeInt64] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeInt64")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsTypeInt64 {
            a: i64,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeInt])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeInt] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeInt")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsTypeInt {
            a: i64,
        }"""
    end
            
    @test begin
        b = JlrsReflect.reflect([BitsTypeFloat32])
        sb = JlrsReflect.StringBindings(b)

        sb[BitsTypeFloat32] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeFloat32")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsTypeFloat32 {
            a: f32,
        }"""
    end
            
    @test begin
        b = JlrsReflect.reflect([BitsTypeFloat64])
        sb = JlrsReflect.StringBindings(b)

        sb[BitsTypeFloat64] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeFloat64")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsTypeFloat64 {
            a: f64,
        }"""
    end
end
