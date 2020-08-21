# JlrsReflect.jl Documentation

One of the main features of jlrs is the possibility to easily convert data from Julia to Rust. By default only a few builtin types, like integers, arrays and modules are available, but this can be extended by using the `JuliaStruct` derive macro. One annoying aspect of this macro is that you need to figure out the correct layout first.

With JlrsReflect.jl you can automatically generate the appropriate bindings for many Julia types if you're using Julia 1.5. This includes types with unions, tuples, and type parameters. Even value types are not a problem because the bindings only contain type parameters that directly affect the layout. If a field contains pointers, featureful wrappers from jlrs with reasonable lifetimes are used. Two things that are not supported are structs with union or tuple fields that depend on a type parameter (eg `struct SomeGenericStruct{T} a::Tuple{Int32, T} end`, `SomeGenericStruct{T} a::Union{Int32, T} end`), and unions used as generic parameters (eg `SomeGenericStruct{Union{A,B}}`).

```@docs
reflect
renamestruct!
renamefields!
```