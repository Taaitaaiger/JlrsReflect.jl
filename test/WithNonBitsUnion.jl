struct NonBitsUnion
    a::Union{String,Real}
end

@testset "Structs with non-bits unions" begin
    @test begin
        b = JlrsReflect.reflect([NonBitsUnion])
        sb = JlrsReflect.StringBindings(b)

        sb[JlrsReflect.basetype(NonBitsUnion)] === """#[repr(C)]
        #[jlrs(julia_type = "Main.NonBitsUnion")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct NonBitsUnion<'frame, 'data> {
            pub a: ::jlrs::value::Value<'frame, 'data>,
        }"""
    end
end
