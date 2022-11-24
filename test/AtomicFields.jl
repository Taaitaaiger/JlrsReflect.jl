mutable struct HasAtomicField
    @atomic a::Int32
end

struct WithInt32
    int32::Int32
end

mutable struct HasCustomAtomicField
    @atomic a::WithInt32
end

@testset "Structs with atomic fields are skipped" begin
    @test begin
        b = JlrsReflect.reflect([HasAtomicField])
        sb = JlrsReflect.StringWrappers(b)

        haskey(sb.dict, JlrsReflect.basetype(HasAtomicField)) == false
    end
end

@testset "Fields of structs with atomic fields are included" begin
    @test begin
        b = JlrsReflect.reflect([HasCustomAtomicField])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithInt32] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, ValidField, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.WithInt32")]
        pub struct WithInt32 {
            pub int32: i32,
        }"""

    end
end
