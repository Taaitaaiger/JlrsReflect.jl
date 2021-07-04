struct WithGenericT{T}
    a::T
end

struct WithNestedGenericT{T}
    a::WithGenericT{T}
end

struct WithSetGeneric
    a::WithGenericT{Int64}
end

struct WithValueType{N}
    a::Int64
end

struct WithGenericUnionAll
    a::WithGenericT
end

struct WithGenericTuple{T}
    a::Tuple{T}
end

struct WithSetGenericTuple
    a::Tuple{WithGenericT{Int64}}
end

struct WithPropagatedLifetime
    a::WithGenericT{Module}
end

struct WithPropagatedLifetimes
    a::WithGenericT{Tuple{Int32, WithGenericT{Array{Int32, 2}}}}
end

@testset "Structs with generic fields" begin
    @test begin
        b = JlrsReflect.reflect([WithGenericT])
        sb = JlrsReflect.StringWrappers(b)

        sb[JlrsReflect.basetype(WithGenericT)] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithGenericT")]
        pub struct WithGenericT<T>
        where
            T: ::jlrs::layout::valid_layout::ValidLayout + Clone,
        {
            pub a: T,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithNestedGenericT])
        sb = JlrsReflect.StringWrappers(b)

        sb[JlrsReflect.basetype(WithNestedGenericT)] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithNestedGenericT")]
        pub struct WithNestedGenericT<T>
        where
            T: ::jlrs::layout::valid_layout::ValidLayout + Clone,
        {
            pub a: WithGenericT<T>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithSetGeneric])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithSetGeneric] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.WithSetGeneric")]
        pub struct WithSetGeneric {
            pub a: WithGenericT<i64>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithValueType])
        sb = JlrsReflect.StringWrappers(b)

        sb[JlrsReflect.basetype(WithValueType)] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithValueType")]
        pub struct WithValueType {
            pub a: i64,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithGenericUnionAll])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithGenericUnionAll] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithGenericUnionAll")]
        pub struct WithGenericUnionAll<'frame, 'data> {
            pub a: ::jlrs::wrappers::ptr::ValueRef<'frame, 'data>,
        }"""
    end

    @test_throws ErrorException begin
        JlrsReflect.reflect([WithGenericTuple])
    end

    @test begin
        b = JlrsReflect.reflect([WithSetGenericTuple])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithSetGenericTuple] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
        #[jlrs(julia_type = "Main.WithSetGenericTuple")]
        pub struct WithSetGenericTuple {
            pub a: ::jlrs::wrappers::inline::tuple::Tuple1<WithGenericT<i64>>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithPropagatedLifetime])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithPropagatedLifetime] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithPropagatedLifetime")]
        pub struct WithPropagatedLifetime<'frame> {
            pub a: WithGenericT<::jlrs::wrappers::ptr::ModuleRef<'frame>>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithPropagatedLifetimes])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithPropagatedLifetimes] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithPropagatedLifetimes")]
        pub struct WithPropagatedLifetimes<'frame, 'data> {
            pub a: WithGenericT<::jlrs::wrappers::inline::tuple::Tuple2<i32, WithGenericT<::jlrs::wrappers::ptr::ArrayRef<'frame, 'data>>>>,
        }"""
    end
end