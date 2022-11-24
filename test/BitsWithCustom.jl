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
        sb = JlrsReflect.StringWrappers(b)

        sb[BitsIntChar] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, ValidField, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsIntChar")]
        pub struct BitsIntChar {
            pub a: i64,
            pub b: ::jlrs::wrappers::inline::char::Char,
        }"""

        sb[BitsCharBitsIntChar] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, ValidField, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.BitsCharBitsIntChar")]
        pub struct BitsCharBitsIntChar {
            pub a: ::jlrs::wrappers::inline::char::Char,
            pub b: BitsIntChar,
        }"""
    end
end
