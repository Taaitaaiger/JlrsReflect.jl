struct BitsIntChar
    a::Int
    b::Char
end

struct BitsCharBitsIntChar
    a::Char
    b::BitsIntChar
end

@testset "Bits types with custom fields" begin
    @test begin
        b = JlrsReflect.reflect([BitsCharBitsIntChar])
        sb = JlrsReflect.StringBindings(b)

        sb[BitsIntChar] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsIntChar")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsIntChar {
            pub a: i64,
            pub b: char,
        }"""

        sb[BitsCharBitsIntChar] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsCharBitsIntChar")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct BitsCharBitsIntChar {
            pub a: char,
            pub b: BitsIntChar,
        }"""
    end
end
