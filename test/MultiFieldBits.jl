struct BitsIntBool
    a::Int
    b::Bool
end

struct BitsCharFloat32Float64
    a::Char
    b::Float32
    c::Float64
end

@testset "Multi-field bits types" begin
    @test begin
        b = JlrsReflect.reflect([BitsIntBool])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsIntBool] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, ValidField, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsIntBool")]
        pub struct BitsIntBool {
            pub a: i64,
            pub b: ::jlrs::wrappers::inline::bool::Bool,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsCharFloat32Float64])
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsCharFloat32Float64] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, ValidField, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsCharFloat32Float64")]
        pub struct BitsCharFloat32Float64 {
            pub a: ::jlrs::wrappers::inline::char::Char,
            pub b: f32,
            pub c: f64,
        }"""
    end
end
