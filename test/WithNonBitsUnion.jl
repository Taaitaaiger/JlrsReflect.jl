struct NonBitsUnion
    a::Union{String,Real}
end

@testset "Structs with non-bits unions" begin
    @test begin
        b = JlrsReflect.reflect([NonBitsUnion])
        sb = JlrsReflect.StringWrappers(b)

        sb[JlrsReflect.basetype(NonBitsUnion)] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.NonBitsUnion")]
        pub struct NonBitsUnion<'frame, 'data> {
            pub a: ::jlrs::wrappers::ptr::ValueRef<'frame, 'data>,
        }"""
    end
end
