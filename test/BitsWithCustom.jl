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
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsIntChar {
            a: i64,
            b: char,
        }"""
    
        sb[BitsCharBitsIntChar] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsCharBitsIntChar")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsCharBitsIntChar {
            a: char,
            b: BitsIntChar,
        }"""
    end
end
