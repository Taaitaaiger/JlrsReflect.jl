struct WithArray
    a::Array{Float32,2}
end

struct WithCodeInstance
    a::Core.CodeInstance
end

struct WithDataType
    a::DataType
end

struct WithExpr
    a::Expr
end

struct WithString
    a::String
end

struct WithMethod
    a::Method
end

struct WithMethodInstance
    a::Core.MethodInstance
end

struct WithMethodTable
    a::Core.MethodTable
end

struct WithModule
    a::Module
end

struct WithSimpleVector
    a::Core.SimpleVector
end

struct WithSymbol
    a::Symbol
end

struct WithTask
    a::Task
end

struct WithTypeName
    a::Core.TypeName
end

struct WithTypeVar
    a::TypeVar
end

struct WithTypeMapEntry
    a::Core.TypeMapEntry
end

struct WithTypeMapLevel
    a::Core.TypeMapLevel
end

struct WithUnion
    a::Union
end

struct WithUnionAll
    a::UnionAll
end

@testset "Structs with builtin fields" begin
    @test begin
        b = JlrsReflect.reflect([WithArray])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithArray] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithArray")]
        pub struct WithArray<'frame, 'data> {
            pub a: ::jlrs::wrappers::ptr::array::ArrayRef<'frame, 'data>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithCodeInstance])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithCodeInstance] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithCodeInstance")]
        pub struct WithCodeInstance<'frame, 'data> {
            pub a: ::jlrs::wrappers::ptr::value::ValueRef<'frame, 'data>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithDataType])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithDataType] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithDataType")]
        pub struct WithDataType<'frame> {
            pub a: ::jlrs::wrappers::ptr::datatype::DataTypeRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithExpr])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithExpr] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithExpr")]
        pub struct WithExpr<'frame, 'data> {
            pub a: ::jlrs::wrappers::ptr::value::ValueRef<'frame, 'data>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithString])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithString] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithString")]
        pub struct WithString<'frame> {
            pub a: ::jlrs::wrappers::ptr::string::StringRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithMethod])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithMethod] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithMethod")]
        pub struct WithMethod<'frame, 'data> {
            pub a: ::jlrs::wrappers::ptr::value::ValueRef<'frame, 'data>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithMethodInstance])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithMethodInstance] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithMethodInstance")]
        pub struct WithMethodInstance<'frame, 'data> {
            pub a: ::jlrs::wrappers::ptr::value::ValueRef<'frame, 'data>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithMethodTable])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithMethodTable] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithMethodTable")]
        pub struct WithMethodTable<'frame, 'data> {
            pub a: ::jlrs::wrappers::ptr::value::ValueRef<'frame, 'data>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithModule])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithModule] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithModule")]
        pub struct WithModule<'frame> {
            pub a: ::jlrs::wrappers::ptr::module::ModuleRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithSimpleVector])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithSimpleVector] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithSimpleVector")]
        pub struct WithSimpleVector<'frame> {
            pub a: ::jlrs::wrappers::ptr::simple_vector::SimpleVectorRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithSymbol])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithSymbol] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithSymbol")]
        pub struct WithSymbol<'frame> {
            pub a: ::jlrs::wrappers::ptr::symbol::SymbolRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithTask])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithTask] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithTask")]
        pub struct WithTask<'frame> {
            pub a: ::jlrs::wrappers::ptr::task::TaskRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithTypeMapEntry])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithTypeMapEntry] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithTypeMapEntry")]
        pub struct WithTypeMapEntry<'frame, 'data> {
            pub a: ::jlrs::wrappers::ptr::value::ValueRef<'frame, 'data>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithTypeMapLevel])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithTypeMapLevel] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithTypeMapLevel")]
        pub struct WithTypeMapLevel<'frame, 'data> {
            pub a: ::jlrs::wrappers::ptr::value::ValueRef<'frame, 'data>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithTypeName])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithTypeName] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithTypeName")]
        pub struct WithTypeName<'frame> {
            pub a: ::jlrs::wrappers::ptr::type_name::TypeNameRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithTypeVar])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithTypeVar] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithTypeVar")]
        pub struct WithTypeVar<'frame> {
            pub a: ::jlrs::wrappers::ptr::type_var::TypeVarRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithUnion])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithUnion] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithUnion")]
        pub struct WithUnion<'frame> {
            pub a: ::jlrs::wrappers::ptr::union::UnionRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithUnionAll])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithUnionAll] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithUnionAll")]
        pub struct WithUnionAll<'frame> {
            pub a: ::jlrs::wrappers::ptr::union_all::UnionAllRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithCodeInstance]; internaltypes=true)
        sb = JlrsReflect.StringWrappers(b)

        sb[WithCodeInstance] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithCodeInstance")]
        pub struct WithCodeInstance<'frame> {
            pub a: ::jlrs::wrappers::ptr::internal::code_instance::CodeInstanceRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithArray])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithArray] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithArray")]
        pub struct WithArray<'frame, 'data> {
            pub a: ::jlrs::wrappers::ptr::array::ArrayRef<'frame, 'data>,
        }"""
    end

    

    @test begin
        b = JlrsReflect.reflect([WithDataType])
        sb = JlrsReflect.StringWrappers(b)

        sb[WithDataType] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithDataType")]
        pub struct WithDataType<'frame> {
            pub a: ::jlrs::wrappers::ptr::datatype::DataTypeRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithExpr]; internaltypes=true)
        sb = JlrsReflect.StringWrappers(b)

        sb[WithExpr] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithExpr")]
        pub struct WithExpr<'frame> {
            pub a: ::jlrs::wrappers::ptr::internal::expr::ExprRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithMethod]; internaltypes=true)
        sb = JlrsReflect.StringWrappers(b)

        sb[WithMethod] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithMethod")]
        pub struct WithMethod<'frame> {
            pub a: ::jlrs::wrappers::ptr::internal::method::MethodRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithMethodInstance]; internaltypes=true)
        sb = JlrsReflect.StringWrappers(b)

        sb[WithMethodInstance] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithMethodInstance")]
        pub struct WithMethodInstance<'frame> {
            pub a: ::jlrs::wrappers::ptr::internal::method_instance::MethodInstanceRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithMethodTable]; internaltypes=true)
        sb = JlrsReflect.StringWrappers(b)

        sb[WithMethodTable] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithMethodTable")]
        pub struct WithMethodTable<'frame> {
            pub a: ::jlrs::wrappers::ptr::internal::method_table::MethodTableRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithTypeMapEntry]; internaltypes=true)
        sb = JlrsReflect.StringWrappers(b)

        sb[WithTypeMapEntry] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithTypeMapEntry")]
        pub struct WithTypeMapEntry<'frame> {
            pub a: ::jlrs::wrappers::ptr::internal::typemap_entry::TypeMapEntryRef<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithTypeMapLevel]; internaltypes=true)
        sb = JlrsReflect.StringWrappers(b)

        sb[WithTypeMapLevel] === """#[repr(C)]
        #[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
        #[jlrs(julia_type = "Main.WithTypeMapLevel")]
        pub struct WithTypeMapLevel<'frame> {
            pub a: ::jlrs::wrappers::ptr::internal::typemap_level::TypeMapLevelRef<'frame>,
        }"""
    end
end
