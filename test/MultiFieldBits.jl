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
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsIntBool] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsIntBool")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsIntBool {
            pub a: i64,
            pub b: bool,
        }"""
    end
        
    @test begin
        b = JlrsReflect.reflect([BitsCharFloat32Float64])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsCharFloat32Float64] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsCharFloat32Float64")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsCharFloat32Float64 {
            pub a: char,
            pub b: f32,
            pub c: f64,
        }"""
    end
end
