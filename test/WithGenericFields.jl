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
        sb = JlrsReflect.StringBindings(b)

        sb[JlrsReflect.basetype(WithGenericT)] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithGenericT")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithGenericT<T>
        where
            T: ::jlrs::traits::ValidLayout + Copy,
        {
            pub a: T,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithNestedGenericT])
        sb = JlrsReflect.StringBindings(b)

        sb[JlrsReflect.basetype(WithNestedGenericT)] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithNestedGenericT")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithNestedGenericT<T>
        where
            T: ::jlrs::traits::ValidLayout + Copy,
        {
            pub a: WithGenericT<T>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithSetGeneric])
        sb = JlrsReflect.StringBindings(b)

        sb[WithSetGeneric] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithSetGeneric")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct WithSetGeneric {
            pub a: WithGenericT<i64>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithValueType])
        sb = JlrsReflect.StringBindings(b)

        sb[JlrsReflect.basetype(WithValueType)] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithValueType")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithValueType {
            pub a: i64,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithGenericUnionAll])
        sb = JlrsReflect.StringBindings(b)

        sb[WithGenericUnionAll] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithGenericUnionAll")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithGenericUnionAll<'frame, 'data> {
            pub a: ::jlrs::value::Value<'frame, 'data>,
        }"""
    end

    @test_throws ErrorException begin
        JlrsReflect.reflect([WithGenericTuple])
    end

    @test begin
        b = JlrsReflect.reflect([WithSetGenericTuple])
        sb = JlrsReflect.StringBindings(b)

        sb[WithSetGenericTuple] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithSetGenericTuple")]
        #[derive(Copy, Clone, Debug, JuliaStruct, IntoJulia)]
        pub struct WithSetGenericTuple {
            pub a: ::jlrs::value::tuple::Tuple1<WithGenericT<i64>>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithPropagatedLifetime])
        sb = JlrsReflect.StringBindings(b)

        sb[WithPropagatedLifetime] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithPropagatedLifetime")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithPropagatedLifetime<'frame> {
            pub a: WithGenericT<::jlrs::value::module::Module<'frame>>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithPropagatedLifetimes])
        sb = JlrsReflect.StringBindings(b)

        sb[WithPropagatedLifetimes] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithPropagatedLifetimes")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithPropagatedLifetimes<'frame, 'data> {
            pub a: WithGenericT<::jlrs::value::tuple::Tuple2<i32, WithGenericT<::jlrs::value::array::Array<'frame, 'data>>>>,
        }"""
    end
end