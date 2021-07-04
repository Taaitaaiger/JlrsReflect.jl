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
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsTypeBool] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsTypeBool")]
        pub struct BitsTypeBool {
            pub a: ::jlrs::wrappers::inline::bool::Bool,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsTypeChar])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsTypeChar] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsTypeChar")]
        pub struct BitsTypeChar {
            pub a: ::jlrs::wrappers::inline::char::Char,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt8])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsTypeUInt8] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsTypeUInt8")]
        pub struct BitsTypeUInt8 {
            pub a: u8,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt16])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsTypeUInt16] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsTypeUInt16")]
        pub struct BitsTypeUInt16 {
            pub a: u16,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt32])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsTypeUInt32] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsTypeUInt32")]
        pub struct BitsTypeUInt32 {
            pub a: u32,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt64])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsTypeUInt64] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsTypeUInt64")]
        pub struct BitsTypeUInt64 {
            pub a: u64,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsTypeUInt])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsTypeUInt] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsTypeUInt")]
        pub struct BitsTypeUInt {
            pub a: u64,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsTypeInt8])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsTypeInt8] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsTypeInt8")]
        pub struct BitsTypeInt8 {
            pub a: i8,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsTypeInt16])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsTypeInt16] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsTypeInt16")]
        pub struct BitsTypeInt16 {
            pub a: i16,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsTypeInt32])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsTypeInt32] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsTypeInt32")]
        pub struct BitsTypeInt32 {
            pub a: i32,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsTypeInt64])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsTypeInt64] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsTypeInt64")]
        pub struct BitsTypeInt64 {
            pub a: i64,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsTypeInt])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsTypeInt] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsTypeInt")]
        pub struct BitsTypeInt {
            pub a: i64,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsTypeFloat32])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsTypeFloat32] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsTypeFloat32")]
        pub struct BitsTypeFloat32 {
            pub a: f32,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsTypeFloat64])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsTypeFloat64] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsTypeFloat64")]
        pub struct BitsTypeFloat64 {
            pub a: f64,
        }"""
    end
end
