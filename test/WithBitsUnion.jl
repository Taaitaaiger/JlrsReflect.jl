struct SingleVariant
    a::Union{Int32}
end

struct DoubleVariant
    a::Union{Int16, Int32}
end

struct SizeAlignMismatch
    a::Union{Tuple{Int16, Int16, Int16}, Int32}
end

struct UnionInTuple
    a::Tuple{Union{Int16, Int32}}
end

struct GenericInUnion{T}
    a::Union{T, Int32}
end

@testset "Structs with bits unions" begin
    @test begin
        b = JlrsReflect.reflect([SingleVariant])
        sb = JlrsReflect.StringWrappers(b)

        sb[JlrsReflect.basetype(SingleVariant)] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.SingleVariant")]
        pub struct SingleVariant {
            pub a: i32,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([DoubleVariant])
        sb = JlrsReflect.StringWrappers(b)

        sb[JlrsReflect.basetype(DoubleVariant)] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.DoubleVariant")]
        pub struct DoubleVariant {
            #[jlrs(bits_union_align)]
            _a_align: ::jlrs::wrappers::inline::union::Align4,
            #[jlrs(bits_union)]
            pub a: ::jlrs::wrappers::inline::union::BitsUnion<4>,
            #[jlrs(bits_union_flag)]
            pub a_flag: u8,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([SizeAlignMismatch])
        sb = JlrsReflect.StringWrappers(b)

        sb[JlrsReflect.basetype(SizeAlignMismatch)] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.SizeAlignMismatch")]
        pub struct SizeAlignMismatch {
            #[jlrs(bits_union_align)]
            _a_align: ::jlrs::wrappers::inline::union::Align4,
            #[jlrs(bits_union)]
            pub a: ::jlrs::wrappers::inline::union::BitsUnion<6>,
            #[jlrs(bits_union_flag)]
            pub a_flag: u8,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([UnionInTuple])
        sb = JlrsReflect.StringWrappers(b)

        sb[JlrsReflect.basetype(UnionInTuple)] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.UnionInTuple")]
        pub struct UnionInTuple<'frame, 'data> {
            pub a: ::jlrs::wrappers::ptr::ValueRef<'frame, 'data>,
        }"""
    end

    @test_throws ErrorException begin
        b = JlrsReflect.reflect([GenericInUnion])
    end
end
