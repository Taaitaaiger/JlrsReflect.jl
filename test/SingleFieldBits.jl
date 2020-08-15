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
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsTypeBool {
            pub a: bool,
        }"""
    end
        
    @test begin
        b = JlrsReflect.reflect([BitsTypeChar])
        sb = JlrsReflect.StringBindings(b)

        sb[BitsTypeChar] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeChar")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsTypeChar {
            pub a: char,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt8])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeUInt8] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeUInt8")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsTypeUInt8 {
            pub a: u8,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt16])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeUInt16] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeUInt16")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsTypeUInt16 {
            pub a: u16,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt32])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeUInt32] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeUInt32")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsTypeUInt32 {
            pub a: u32,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt64])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeUInt64] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeUInt64")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsTypeUInt64 {
            pub a: u64,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeUInt] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeUInt")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsTypeUInt {
            pub a: u64,
        }"""
    end    

    @test begin
        b = JlrsReflect.reflect([BitsTypeInt8])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeInt8] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeInt8")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsTypeInt8 {
            pub a: i8,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeInt16])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeInt16] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeInt16")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsTypeInt16 {
            pub a: i16,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeInt32])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeInt32] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeInt32")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsTypeInt32 {
            pub a: i32,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeInt64])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeInt64] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeInt64")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsTypeInt64 {
            pub a: i64,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([BitsTypeInt])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsTypeInt] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeInt")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsTypeInt {
            pub a: i64,
        }"""
    end
            
    @test begin
        b = JlrsReflect.reflect([BitsTypeFloat32])
        sb = JlrsReflect.StringBindings(b)

        sb[BitsTypeFloat32] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeFloat32")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsTypeFloat32 {
            pub a: f32,
        }"""
    end
            
    @test begin
        b = JlrsReflect.reflect([BitsTypeFloat64])
        sb = JlrsReflect.StringBindings(b)

        sb[BitsTypeFloat64] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsTypeFloat64")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsTypeFloat64 {
            pub a: f64,
        }"""
    end
end
