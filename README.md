# JlrsReflect

[![Build Status](https://travis-ci.com/Taaitaaiger/JlrsReflect.jl.svg?branch=master)](https://travis-ci.com/Taaitaaiger/JlrsReflect.jl)
[![Coverage](https://codecov.io/gh/Taaitaaiger/JlrsReflect.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Taaitaaiger/JlrsReflect.jl)

One of the main features of jlrs is the possibility to easily convert data from Julia to Rust. By default only a few builtin types, like integers, arrays and modules are available, but this can be extended by using the derive macro from jlrs-derive. One annoying aspect of these macros is that you need to figure out the correct layout first.

With JlrsReflect.jl you can automatically generate wrappers for many Julia types that are compatible with jlrs 0.11. This includes types with unions, tuples, and type parameters. Even value types are not a problem because the wrappers only contain type parameters that directly affect the layout. If a field contains pointers, the `Ref` types from jlrs are used. Two things that are not supported are structs with union or tuple fields that depend on a type parameter (eg `struct SomeGenericStruct{T} a::Tuple{Int32, T} end`, `SomeGenericStruct{T} a::Union{Int32, T} end`), and unions used as generic parameters (eg `SomeGenericStruct{Union{A,B}}`).

You can use this package by calling the `reflect` function with a `Vector` of types:

```julia
struct TypeA
    ...fields
end

struct TypeB{T}
    ...fields
end

...

wrappers = JlrsReflect.reflect([TypeA, TypeB, ...]);

# Print wrappers to standard output
println(wrappers)

# Write wrappers to file
open("julia_wrappers.rs", "w") do f
    write(f, wrappers)
end
```

Wrappers for types used as fields and type parameters are automatically generated. If you want or need to rename structs or their fields you can use `renamestruct!` and `renamefields!` as follows:

```julia
wrappers = JlrsReflect.reflect([TypeA, TypeB, ...])
renamestruct!(wrappers, TypeA, "StructA")
renamefields!(wrappers, TypeB, [:fielda => "field_a", :fieldb => "field_b"])
```
