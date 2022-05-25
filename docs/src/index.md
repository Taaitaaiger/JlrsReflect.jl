# JlrsReflect.jl Documentation

This package can be used to generate jlrs-compatible Rust implementations of Julia structs (wrappers).

Wrappers can be generated for many structs, including structs with union fields, tuple fields, and type parameters. Wrappers are recursively generated for all of a type's fields, and are always generated for the most general case; any provided type parameter is erased and included in the set of structs for which wrappers are generated.

Three things that are not supported are structs with union or tuple fields that depend on a type parameter (eg `struct SomeGenericStruct{T} a::Tuple{Int32, T} end`, `SomeGenericStruct{T} a::Union{Int32, T} end`), unions used as generic parameters (eg `SomeGenericStruct{Union{A,B}}`), and structs with atomic fields. An error is thrown in the first two cases, in the final case no wrapper is generated for the struct itself but wrappers for all of its dependencies will be generated.

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
