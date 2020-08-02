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
        sb = JlrsReflect.StringBindings(b)

        sb[JlrsReflect.basetype(SingleVariant)] === """#[repr(C)]
        #[jlrs(julia_type = "Main.SingleVariant")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct SingleVariant {
            a: i32,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([DoubleVariant])
        sb = JlrsReflect.StringBindings(b)

        sb[JlrsReflect.basetype(DoubleVariant)] === """#[repr(C)]
        #[jlrs(julia_type = "Main.DoubleVariant")]
        #[derive(Copy, Clone, JuliaStruct)]
        struct DoubleVariant {
            #[jlrs(bits_union_align)]
            _a_align: ::jlrs::value::union::Align4,
            #[jlrs(bits_union)]
            a: ::jlrs::value::union::BitsUnion<[::std::mem::MaybeUninit<u8>; 4]>,
            #[jlrs(bits_union_flag)]
            _a_flag: u8,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([SizeAlignMismatch])
        sb = JlrsReflect.StringBindings(b)

        sb[JlrsReflect.basetype(SizeAlignMismatch)] === """#[repr(C)]
        #[jlrs(julia_type = "Main.SizeAlignMismatch")]
        #[derive(Copy, Clone, JuliaStruct)]
        struct SizeAlignMismatch {
            #[jlrs(bits_union_align)]
            _a_align: ::jlrs::value::union::Align4,
            #[jlrs(bits_union)]
            a: ::jlrs::value::union::BitsUnion<[::std::mem::MaybeUninit<u8>; 6]>,
            #[jlrs(bits_union_flag)]
            _a_flag: u8,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([UnionInTuple])
        sb = JlrsReflect.StringBindings(b)

        sb[JlrsReflect.basetype(UnionInTuple)] === """#[repr(C)]
        #[jlrs(julia_type = "Main.UnionInTuple")]
        #[derive(Copy, Clone, JuliaStruct)]
        struct UnionInTuple<'frame, 'data> {
            a: ::jlrs::value::Value<'frame, 'data>,
        }"""
    end

    @test_throws ErrorException begin
        b = JlrsReflect.reflect([GenericInUnion])
    end
end
