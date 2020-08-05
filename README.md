# JlrsReflect

[![Build Status](https://travis-ci.com/Taaitaaiger/JlrsReflect.jl.svg?branch=master)](https://travis-ci.com/Taaitaaiger/JlrsReflect.jl)
[![Coverage](https://codecov.io/gh/Taaitaaiger/JlrsReflect.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Taaitaaiger/JlrsReflect.jl)

One of the main features of jlrs is the possibility to easily convert data from Julia to Rust. By default only a few builtin types, like integers, arrays and modules are available, but this can be extended by using the `JuliaStruct` derive macro. One annoying aspect of this macro is that you need to figure out the correct layout first.

With JlrsReflect.jl you can automatically generate the appropriate bindings for many Julia types. This includes types with unions, tuples, and type parameters. Even value types are not a problem because the bindings only contain type parameters that directly affect the layout and lifetimes referenced by the fields. Two things that are not supported are structs with union or tuple fields that depend on a type parameter. 

You can use this package by calling the `reflect` function with a `Vector` of types (both `DataType`s and `UnionAll`s are supported):

```julia
struct TypeA
    ...fields
end

struct TypeB{T}
    ...fields
end

...

bindings = JlrsReflect.reflect([TypeA, TypeB, ...])

# Print bindings to standard output
println(bindings)

# Write bindings to file
open("julia_bindings.rs", "w") f do
    write(f, bindings)
end
```

Bindings for types used as fields and type parameters are automatically generated. 
