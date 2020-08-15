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
        sb = JlrsReflect.StringBindings(b)

        sb[WithArray] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithArray")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithArray<'frame, 'data> {
            pub a: ::jlrs::value::array::Array<'frame, 'data>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithCodeInstance])
        sb = JlrsReflect.StringBindings(b)

        sb[WithCodeInstance] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithCodeInstance")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithCodeInstance<'frame> {
            pub a: ::jlrs::value::code_instance::CodeInstance<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithDataType])
        sb = JlrsReflect.StringBindings(b)

        sb[WithDataType] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithDataType")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithDataType<'frame> {
            pub a: ::jlrs::value::datatype::DataType<'frame>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([WithExpr])
        sb = JlrsReflect.StringBindings(b)

        sb[WithExpr] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithExpr")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithExpr<'frame> {
            pub a: ::jlrs::value::expr::Expr<'frame>,
        }"""
    end
    
    @test begin
        b = JlrsReflect.reflect([WithString])
        sb = JlrsReflect.StringBindings(b)

        sb[WithString] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithString")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithString<'frame> {
            pub a: ::jlrs::value::string::JuliaString<'frame>,
        }"""
    end
        
    @test begin
        b = JlrsReflect.reflect([WithMethod])
        sb = JlrsReflect.StringBindings(b)

        sb[WithMethod] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithMethod")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithMethod<'frame> {
            pub a: ::jlrs::value::method::Method<'frame>,
        }"""
    end
            
    @test begin
        b = JlrsReflect.reflect([WithMethodInstance])
        sb = JlrsReflect.StringBindings(b)

        sb[WithMethodInstance] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithMethodInstance")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithMethodInstance<'frame> {
            pub a: ::jlrs::value::method_instance::MethodInstance<'frame>,
        }"""
    end
                
    @test begin
        b = JlrsReflect.reflect([WithMethodTable])
        sb = JlrsReflect.StringBindings(b)

        sb[WithMethodTable] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithMethodTable")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithMethodTable<'frame> {
            pub a: ::jlrs::value::method_table::MethodTable<'frame>,
        }"""
    end
                    
    @test begin
        b = JlrsReflect.reflect([WithModule])
        sb = JlrsReflect.StringBindings(b)

        sb[WithModule] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithModule")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithModule<'frame> {
            pub a: ::jlrs::value::module::Module<'frame>,
        }"""
    end
                        
    @test begin
        b = JlrsReflect.reflect([WithSimpleVector])
        sb = JlrsReflect.StringBindings(b)

        sb[WithSimpleVector] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithSimpleVector")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithSimpleVector<'frame> {
            pub a: ::jlrs::value::simple_vector::SimpleVector<'frame>,
        }"""
    end
                            
    @test begin
        b = JlrsReflect.reflect([WithSymbol])
        sb = JlrsReflect.StringBindings(b)

        sb[WithSymbol] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithSymbol")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithSymbol<'frame> {
            pub a: ::jlrs::value::symbol::Symbol<'frame>,
        }"""
    end
                                
    @test begin
        b = JlrsReflect.reflect([WithTask])
        sb = JlrsReflect.StringBindings(b)

        sb[WithTask] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithTask")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithTask<'frame> {
            pub a: ::jlrs::value::task::Task<'frame>,
        }"""
    end
                                    
    @test begin
        b = JlrsReflect.reflect([WithTypeMapEntry])
        sb = JlrsReflect.StringBindings(b)

        sb[WithTypeMapEntry] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithTypeMapEntry")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithTypeMapEntry<'frame> {
            pub a: ::jlrs::value::typemap_entry::TypeMapEntry<'frame>,
        }"""
    end
                                        
    @test begin
        b = JlrsReflect.reflect([WithTypeMapLevel])
        sb = JlrsReflect.StringBindings(b)

        sb[WithTypeMapLevel] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithTypeMapLevel")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithTypeMapLevel<'frame> {
            pub a: ::jlrs::value::typemap_level::TypeMapLevel<'frame>,
        }"""
    end
                                            
    @test begin
        b = JlrsReflect.reflect([WithTypeName])
        sb = JlrsReflect.StringBindings(b)

        sb[WithTypeName] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithTypeName")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithTypeName<'frame> {
            pub a: ::jlrs::value::type_name::TypeName<'frame>,
        }"""
    end
                                                
    @test begin
        b = JlrsReflect.reflect([WithTypeVar])
        sb = JlrsReflect.StringBindings(b)

        sb[WithTypeVar] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithTypeVar")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithTypeVar<'frame> {
            pub a: ::jlrs::value::type_var::TypeVar<'frame>,
        }"""
    end
                                                 
    @test begin
        b = JlrsReflect.reflect([WithUnion])
        sb = JlrsReflect.StringBindings(b)

        sb[WithUnion] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithUnion")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithUnion<'frame> {
            pub a: ::jlrs::value::union::Union<'frame>,
        }"""
    end
                                                     
    @test begin
        b = JlrsReflect.reflect([WithUnionAll])
        sb = JlrsReflect.StringBindings(b)

        sb[WithUnionAll] === """#[repr(C)]
        #[jlrs(julia_type = "Main.WithUnionAll")]
        #[derive(Copy, Clone, Debug, JuliaStruct)]
        pub struct WithUnionAll<'frame> {
            pub a: ::jlrs::value::union_all::UnionAll<'frame>,
        }"""
    end
end
