# JlrsReflect.jl Documentation

One of the features of jlrs, a crate that provides bindings to the Julia C API for the Rust programming language, is that it supports mapping a struct from Julia to a Rust struct which lets you access its contents directly. Writing down the correct implementation of these structs in Rust can be challenging, this package can be used to automate the process.

Many types are supported, the major exceptions are types with tuple or union fields that depend on a free type parameter. These fields can have very different representations depending on these parameters which makes generating an appropriate mapping impossible. Everything else is fine, though; Types with bits union fields, `UnionAll` fields, type parameters, and "special" types backed by a struct defined in C like `Module` and `Array` are all supported.

There is a single entrypoint, the `reflect` method which takes a `Vector` of `Type`s. Mappings will be generated for all of these types and their dependencies. The result of a call to this method can be written to a .rs-file and used as a module without any tweaking. 

This package is compatible with Julia v1.5 and jlrs v0.6.

```@docs
reflect
```