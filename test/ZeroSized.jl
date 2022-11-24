struct Empty end

struct TypedEmpty{T} end

@testset "Struct with no fields" begin
    @test begin
        b = JlrsReflect.reflect([Empty])
        sb = JlrsReflect.StringWrappers(b)

        sb[Empty] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, ValidField, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.Empty", zero_sized_type)]
        pub struct Empty {
        }"""
    end
end

@testset "Struct with type parameter but no fields" begin
    @test begin
        b = JlrsReflect.reflect([TypedEmpty])
        sb = JlrsReflect.StringWrappers(b)

        sb[JlrsReflect.basetype(TypedEmpty)] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, ValidField, Typecheck)]
        #[jlrs(julia_type = "Main.TypedEmpty")]
        pub struct TypedEmpty {
        }"""
    end
end
