module JlrsReflect

export reflect, renamestruct!, renamefields!

import Base: show, getindex, write

abstract type Wrapper end

struct StructParameter
    name::Symbol
    elide::Bool
end

struct TypeParameter
    name::Symbol
    value
end

struct GenericWrapper <: Wrapper
    name::Symbol
end

mutable struct StructField
    name::Symbol
    rsname::String
    fieldtype::Wrapper
    typeparams::Vector{TypeParameter}
    referenced::Set{TypeVar}
    framelifetime::Bool
    datalifetime::Bool
end

struct BitsUnionWrapper <: Wrapper
    union_of::Union
    typeparams::Vector{StructParameter}
    framelifetime::Bool
    datalifetime::Bool
    BitsUnionWrapper(union_of::Union) = new(union_of, [], false, false)
end

mutable struct StructWrapper <: Wrapper
    name::Symbol
    typename::Core.TypeName
    rsname::String
    fields::Vector{StructField}
    typeparams::Vector{StructParameter}
    framelifetime::Bool
    datalifetime::Bool
end

struct TupleField
    fieldtype::Wrapper
    typeparams::Vector{TypeParameter}
    framelifetime::Bool
    datalifetime::Bool
end

struct TupleWrapper <: Wrapper
    rsname::String
    fields::Vector{TupleField}
    framelifetime::Bool
    datalifetime::Bool
    TupleWrapper(fields::Vector{TupleField}, framelifetime::Bool, datalifetime::Bool) = new(string("::jlrs::wrappers::inline::tuple::Tuple", length(fields)), fields, framelifetime, datalifetime)
end

struct BuiltinWrapper <: Wrapper
    rsname::String
    typeparams::Vector{StructParameter}
    framelifetime::Bool
    datalifetime::Bool
end

struct Wrappers
    dict::Dict{Type,Wrapper}
end

struct StringWrappers
    dict::Dict{Type,String}
end

function StringWrappers(wrappers::Wrappers)
    strwrappers = Dict{Type,String}()

    for name in keys(wrappers.dict)
        rustimpl = strwrapper(wrappers.dict[name], wrappers.dict)
        if rustimpl !== nothing
            strwrappers[name] = rustimpl
        end
    end

    StringWrappers(strwrappers)
end

function getindex(sb::StringWrappers, els...)
    sb.dict[els...]
end

function show(io::IO, wrappers::Wrappers)
    rustimpls = []
    names = []

    for name in keys(wrappers.dict)
        push!(names, name)
    end

    for name in sort(names, lt=(a, b) -> string(a) < string(b))
        rustimpl = strwrapper(wrappers.dict[name], wrappers.dict)
        if rustimpl !== nothing
            push!(rustimpls, rustimpl)
        end
    end

    print(io, join(rustimpls, "\n\n"))
end

function write(io::IO, wrappers::Wrappers)
    rustimpls = ["use jlrs::prelude::*;"]
    names = []

    for name in keys(wrappers.dict)
        push!(names, name)
    end

    for name in sort(names, lt=(a, b) -> string(a) < string(b))
        rustimpl = strwrapper(wrappers.dict[name], wrappers.dict)
        if rustimpl !== nothing
            push!(rustimpls, rustimpl)
        end
    end

    write(io, join(rustimpls, "\n\n"), "\n")
end

function insertbuiltins!(wrappers::Dict{Type,Wrapper})::Nothing
    wrappers[UInt8] = BuiltinWrapper("u8", [], false, false)
    wrappers[UInt16] = BuiltinWrapper("u16", [], false, false)
    wrappers[UInt32] = BuiltinWrapper("u32", [], false, false)
    wrappers[UInt64] = BuiltinWrapper("u64", [], false, false)
    wrappers[Int8] = BuiltinWrapper("i8", [], false, false)
    wrappers[Int16] = BuiltinWrapper("i16", [], false, false)
    wrappers[Int32] = BuiltinWrapper("i32", [], false, false)
    wrappers[Int64] = BuiltinWrapper("i64", [], false, false)
    wrappers[Float16] = BuiltinWrapper("::half::f16", [], false, false)
    wrappers[Float32] = BuiltinWrapper("f32", [], false, false)
    wrappers[Float64] = BuiltinWrapper("f64", [], false, false)
    wrappers[Bool] = BuiltinWrapper("::jlrs::wrappers::inline::bool::Bool", [], false, false)
    wrappers[Char] = BuiltinWrapper("::jlrs::wrappers::inline::char::Char", [], false, false)
    wrappers[Core.SSAValue] = BuiltinWrapper("::jlrs::wrappers::inline::ssa_value::SSAValue", [], false, false)
    wrappers[Union{}] = BuiltinWrapper("::jlrs::wrappers::inline::union::EmptyUnion", [], false, false)

    wrappers[Any] = BuiltinWrapper("::jlrs::wrappers::ptr::ValueRef", [], true, true)
    wrappers[basetype(Array)] = BuiltinWrapper("::jlrs::wrappers::ptr::ArrayRef", [StructParameter(:T, true), StructParameter(:N, true)], true, true)
    wrappers[Core.CodeInstance] = BuiltinWrapper("::jlrs::wrappers::ptr::CodeInstanceRef", [], true, false)
    wrappers[DataType] = BuiltinWrapper("::jlrs::wrappers::ptr::DataTypeRef", [], true, false)
    wrappers[Expr] = BuiltinWrapper("::jlrs::wrappers::ptr::ExprRef", [], true, false)
    wrappers[Method] = BuiltinWrapper("::jlrs::wrappers::ptr::MethodRef", [], true, false)
    wrappers[Core.MethodInstance] = BuiltinWrapper("::jlrs::wrappers::ptr::MethodInstanceRef", [], true, false)
    wrappers[Core.MethodMatch] = BuiltinWrapper("::jlrs::wrappers::ptr::MethodMatchRef", [], true, false)
    wrappers[Core.MethodTable] = BuiltinWrapper("::jlrs::wrappers::ptr::MethodTableRef", [], true, false)
    wrappers[Core.Method] = BuiltinWrapper("::jlrs::wrappers::ptr::MethodRef", [], true, false)
    wrappers[Module] = BuiltinWrapper("::jlrs::wrappers::ptr::ModuleRef", [], true, false)
    wrappers[Core.SimpleVector] = BuiltinWrapper("::jlrs::wrappers::ptr::SimpleVectorRef", [], true, false)
    wrappers[String] = BuiltinWrapper("::jlrs::wrappers::ptr::StringRef", [], true, false)
    wrappers[Symbol] = BuiltinWrapper("::jlrs::wrappers::ptr::SymbolRef", [], true, false)
    wrappers[Task] = BuiltinWrapper("::jlrs::wrappers::ptr::TaskRef", [], true, false)
    wrappers[Core.TypeName] = BuiltinWrapper("::jlrs::wrappers::ptr::TypeNameRef", [], true, false)
    wrappers[TypeVar] = BuiltinWrapper("::jlrs::wrappers::ptr::TypeVarRef", [], true, false)
    wrappers[Core.TypeMapEntry] = BuiltinWrapper("::jlrs::wrappers::ptr::TypeMapEntryRef", [], true, false)
    wrappers[Core.TypeMapLevel] = BuiltinWrapper("::jlrs::wrappers::ptr::TypeMapLevelRef", [], true, false)
    wrappers[Union] = BuiltinWrapper("::jlrs::wrappers::ptr::UnionRef", [], true, false)
    wrappers[UnionAll] = BuiltinWrapper("::jlrs::wrappers::ptr::UnionAllRef", [], true, false)
    wrappers[WeakRef] = BuiltinWrapper("::jlrs::wrappers::ptr::WeakRefRef", [], true, false)

    nothing
end

function toposort!(data::Dict{DataType,Set{DataType}})::Vector{Type}
    for (k, v) in data
        delete!(v, k)
    end

    for item in setdiff(reduce(∪, values(data)), keys(data))
        data[item] = Set()
    end

    rst = Vector()
    while true
        ordered = Set(item for (item, dep) in data if isempty(dep))
        if isempty(ordered) break end
        append!(rst, ordered)
        data = Dict(item => setdiff(dep, ordered) for (item, dep) in data if item ∉ ordered)
    end

    @assert isempty(data) "a cyclic dependency exists amongst $(keys(data))"
    rst
end

function partialtype(type::UnionAll)::DataType
    t = type

    while t.body isa UnionAll
        t = t.body
    end

    return t.body
end

function partialtype(type::DataType)::DataType
    return type
end

function basetype(type::DataType)::DataType
    definition = getproperty(type.name.module, type.name.name)
    partialtype(definition)
end

function basetype(type::UnionAll)::DataType
    partial = partialtype(type)
    definition = getproperty(partial.name.module, partial.name.name)
    partialtype(definition)
end

const BUILTINS = begin
    d = Dict{Type,Wrapper}()
    insertbuiltins!(d)
    d
end

function isnonparametric(type::Union)::Bool
    for utype in Base.uniontypes(type)
        if utype isa DataType
            if findfirst(utype.parameters) do p p isa TypeVar end !== nothing
                return false
            end

            continue
        elseif utype isa TypeVar
            return false
        end
    end

    true
end

function extracttupledeps!(acc::Dict{DataType,Set{DataType}}, type::DataType)::Nothing
    for ttype in type.types
        extractdeps!(acc, ttype)
    end

    nothing
end

function extracttupledeps!(acc::Dict{DataType,Set{DataType}}, key::DataType, type::DataType)::Nothing
    for ttype in type.types
        if ttype isa DataType
            if ttype <: Tuple
                if !isconcretetype(ttype)
                    extracttupledeps!(acc, ttype)
                else
                    extracttupledeps!(acc, key, ttype)
                end
            else
                tbase = basetype(ttype)
                push!(acc[key], tbase)
                extractdeps!(acc, ttype)
            end
        elseif ttype isa Union
            extractdeps!(acc, ttype)
        end
    end

    nothing
end

function extractdeps!(acc::Dict{DataType,Set{DataType}}, type::Type)::Nothing
    if type isa DataType
        if type <: Tuple
            return extracttupledeps!(acc, type)
        elseif isabstracttype(type)
            return
        end

        partial = partialtype(type)
        base = basetype(type)

        if !(base in keys(acc)) && !(base in keys(BUILTINS) )
            acc[base] = Set()

            for btype in base.types
                if btype isa DataType
                    if btype <: Tuple
                        if findfirst(btype.parameters) do p p isa TypeVar end !== nothing
                            error("Tuple fields with type parameters are not supported")
                        elseif !isconcretetype(btype)
                            extracttupledeps!(acc, btype)
                        else
                            extracttupledeps!(acc, type, btype)
                        end
                    else
                        bbase = basetype(btype)
                        push!(acc[base], bbase)
                        extractdeps!(acc, btype)
                    end
                elseif btype isa UnionAll
                    extractdeps!(acc, btype)
                elseif btype isa Union
                    if !isnonparametric(btype)
                        error("Unions with type parameters are not supported")
                    end
                    extractdeps!(acc, btype)
                end
            end
        end

        btypes = base.parameters
        ptypes = partial.parameters

        for i in 1:length(btypes)
            btype = btypes[i]
            ptype = ptypes[i]
            if btype isa TypeVar && ptype isa Type
                extractdeps!(acc, ptype)
            end
        end
    elseif type isa UnionAll
        extractdeps!(acc, partialtype(type))
    elseif type isa Union
        for uniontype in Base.uniontypes(type)
            if uniontype isa TypeVar
                error("Unions with type parameters are not supported")
            end

            extractdeps!(acc, uniontype)
        end
    end

    nothing
end

function extractparams(ty::Type, wrappers::Dict{Type,Wrapper})::Set{TypeVar}
    out = Set()
    if ty <: Tuple
        for elty in ty.parameters
            union!(out, extractparams(elty, wrappers))
        end

        return out
    elseif ty isa Union
        return out
    elseif isabstracttype(ty)
        return out
    end

    partial = partialtype(ty)
    base = basetype(ty)

    wrapper = wrappers[base]

    if !hasproperty(partial, :parameters)
        return out
    end

    for (name, param) in zip(wrapper.typeparams, partial.parameters)
        if !name.elide
            if param isa TypeVar
                idx = findfirst(t -> t.name == name.name, wrapper.typeparams)
                if idx !== nothing
                    push!(out, param)
                end
            elseif param isa Type
                union!(out, extractparams(param, wrappers))
            end
        end
    end

    out
end

function concretetuplefield(tuple::Type, wrappers::Dict{Type,Wrapper})::TupleWrapper
    framelifetime = false
    datalifetime = false
    fieldwrappers::Vector{TupleField} = []

    for ty in tuple.types
        fieldwrapper = if ty isa DataType
            if Base.uniontype_layout(ty)[1]
                if ty <: Tuple
                    b = concretetuplefield(ty, wrappers)
                    framelifetime |= b.framelifetime
                    datalifetime |= b.datalifetime
                    TupleField(b, [], b.framelifetime, b.datalifetime)
                else
                    bty = basetype(ty)
                    b = wrappers[bty]
                    tparams = map(a -> TypeParameter(a[1].name, a[2]), zip(bty.parameters, ty.parameters))
                    framelifetime |= b.framelifetime
                    datalifetime |= b.datalifetime
                    TupleField(b, tparams, b.framelifetime, b.datalifetime)
                end
            elseif ty in keys(wrappers)
                b = wrappers[ty]
                if b isa BuiltinWrapper
                    framelifetime |= b.framelifetime
                    datalifetime |= b.datalifetime
                    TupleField(b, [], b.framelifetime, b.datalifetime)
                else
                    framelifetime = true
                    datalifetime = true
                    TupleField(wrappers[Any], [], true, true)
                end
            else
                framelifetime = true
                datalifetime = true
                TupleField(wrappers[Any], [], true, true)
            end
        else
            error("Invalid type")
        end

        push!(fieldwrappers, fieldwrapper)
    end

    TupleWrapper(fieldwrappers, framelifetime, datalifetime)
end


function structfield(fieldname::Symbol, fieldtype::Union{Type,TypeVar}, wrappers::Dict{Type,Wrapper})::StructField
    if fieldtype isa TypeVar
        StructField(fieldname, string(fieldname), GenericWrapper(fieldtype.name), [TypeParameter(fieldtype.name, fieldtype)], Set([fieldtype]), false, false)
    elseif fieldtype isa UnionAll
        bt = basetype(fieldtype)

        if bt isa Union
            error("Unions with type parameters are not supported")
        elseif bt.name.name == :Array
            fieldwrapper = wrappers[bt]
            tparams = map(a -> TypeParameter(a[1].name, a[2]), zip(bt.parameters, bt.parameters))
            references = extractparams(bt, wrappers)
            StructField(fieldname, string(fieldname), fieldwrapper, tparams, references, fieldwrapper.framelifetime, fieldwrapper.datalifetime)
        else
            StructField(fieldname, string(fieldname), wrappers[Any], [], Set(), true, true)
        end
    elseif fieldtype isa Union
        if Base.isbitsunion(fieldtype)
            StructField(fieldname, string(fieldname), BitsUnionWrapper(fieldtype), [], Set(), false, false)
        else
            StructField(fieldname, string(fieldname), wrappers[Any], [], Set(), true, true)
        end
    elseif fieldtype == Union{}
        StructField(fieldname, string(fieldname), wrappers[Union{}], [], Set(), false, false)
    elseif fieldtype <: Tuple
        params = extractparams(fieldtype, wrappers)
        if length(params) > 0
            error("Tuples with type parameters are not supported")
        elseif isconcretetype(fieldtype)
            wrapper = concretetuplefield(fieldtype, wrappers)
            StructField(fieldname, string(fieldname), wrapper, [], Set(), wrapper.framelifetime, wrapper.datalifetime)
        else
            StructField(fieldname, string(fieldname), wrappers[Any], [], Set(), true, true)
        end
    elseif fieldtype isa DataType
        bt = basetype(fieldtype)
        if bt in keys(wrappers)
            fieldwrapper = wrappers[bt]
            tparams = map(a -> TypeParameter(a[1].name, a[2]), zip(bt.parameters, fieldtype.parameters))
            references = extractparams(fieldtype, wrappers)
            StructField(fieldname, string(fieldname), fieldwrapper, tparams, references, fieldwrapper.framelifetime, fieldwrapper.datalifetime)
        elseif Base.uniontype_layout(fieldtype)[1]
            StructField(fieldname, string(fieldname), wrappers[Any], [], Set(), true, true)
        else
            error("Cannot create field wrapper")
        end
    else
        error("Unknown field type")
    end
end

function createwrapper!(wrappers::Dict{Type,Wrapper}, type::Type)::Nothing
    bt = basetype(type)

    if isdefined(Core, :OpaqueClosure) && bt <: Core.OpaqueClosure
        error("Core.OpaqueClosure is not supported")
    end

    if bt in keys(wrappers) return end

    if isabstracttype(bt)
        wrappers[bt] = wrappers[Any]
        return
    end

    fields = []
    framelifetime = false
    datalifetime = false
    typevars = Set()
    for (name, ty) in zip(fieldnames(bt), fieldtypes(bt))
        field = structfield(name, ty, wrappers)
        framelifetime |= field.framelifetime
        datalifetime |= field.datalifetime
        union!(typevars, field.referenced)
        push!(fields, field)
    end

    params = map(a -> StructParameter(a.name, !(a in typevars)), bt.parameters)
    wrappers[bt] = StructWrapper(type.name.name, type.name, string(type.name.name), fields, params, framelifetime, datalifetime)
    nothing
end

function haslifetimes(ty::Type, wrappers::Dict{Type,JlrsReflect.Wrapper})::Tuple{Bool,Bool}
    framelifetime = false

    if ty <: Tuple
        if isconcretetype(ty)
            for fty in ty.types
                framelt, datalt = haslifetimes(fty, wrappers)
                if datalt
                    return (true, true)
                end

                framelifetime |= framelt
            end
        else
            return (true, true)
        end
    else
        bt = basetype(ty)
        wrapper = wrappers[bt]

        if wrapper.datalifetime
            return (true, true)
        end

        framelifetime |= wrapper.framelifetime

        if wrapper isa StructWrapper
            for param in ty.parameters
                if param isa Type
                    framelt, datalt = haslifetimes(param, wrappers)
                    if datalt
                        return (true, true)
                    end

                    framelifetime |= framelt
                end
            end
        end
    end

    (framelifetime, false)
end

function setparamlifetimes!(wrappers::Dict{Type,JlrsReflect.Wrapper})::Nothing
    for (ty, wrapper) in wrappers
        if wrapper isa StructWrapper
            framelifetime = wrapper.framelifetime
            datalifetime = wrapper.datalifetime

            if datalifetime
                continue
            end

            for field in wrapper.fields
                for param in field.typeparams
                    if param.value !== nothing && !(param.value isa TypeVar)
                        framelt, datalt = haslifetimes(param.value, wrappers)
                        if datalt
                            framelifetime = true
                            datalifetime = true
                            break
                        end

                        framelifetime |= framelt
                    end
                end

                if wrapper.datalifetime
                    break
                end
            end

            wrapper.framelifetime = framelifetime
            wrapper.datalifetime = datalifetime
        end
    end

    nothing
end

"""
    reflect(types::Vector{<:Type})::Wrappers

Generate Rust wrappers for all types in `types` and their dependencies. The only requirement is
that these types must not contain any union or tuple fields that depend on a type parameter.
Wrappers are generated for the most general case by erasing the contents of all provided type
parameters, so you can't avoid this restriction by explicitly providing a more qualified type.
The only effect qualifying types has, is that wrappers for the used parameters will also be
generated. The wrappers will derive `Unbox` and `ValidLayout`, and `IntoJulia` if it's a
bits-type with no type parameters.

The result of this function can be written to a file, its contents will normally be a valid Rust
module.

When you use these wrappers with jlrs, these types must be available with the same path. For
example, if you generate wrappers for `Main.Bar.Baz`, this type must be available through that
exact path and not some other path like `Main.Foo.Bar.Baz`.

# Example
```jldoctest
julia> using JlrsReflect

julia> reflect([Complex])
#[repr(C)]
#[derive(Clone, Debug, Unbox, ValidLayout, Typecheck)]
#[jlrs(julia_type = "Base.Complex")]
pub struct Complex<T>
where
    T: ::jlrs::layout::valid_layout::ValidLayout + Clone,
{
    pub re: T,
    pub im: T,
}
```
"""
function reflect(types::Vector{<:Type})::Wrappers
    deps = Dict{DataType,Set{DataType}}()
    for ty in types
        extractdeps!(deps, ty)
    end

    wrappers = Dict{Type,Wrapper}()
    insertbuiltins!(wrappers)

    for ty in toposort!(deps)
        createwrapper!(wrappers, ty)
    end

    setparamlifetimes!(wrappers)
    Wrappers(wrappers)
end

function strgenerics(wrapper::StructWrapper)::Union{Nothing,String}
    generics = []
    wheres = []
    if wrapper.framelifetime
        push!(generics, "'frame")
    end

    if wrapper.datalifetime
        push!(generics, "'data")
    end

    for param in wrapper.typeparams
        if !param.elide
            push!(generics, string(param.name))
            push!(wheres, string("    ", param.name, ": ::jlrs::layout::valid_layout::ValidLayout + Clone,"))
        end
    end

    if length(generics) > 0
        wh = if length(wheres) > 0
            string("\nwhere\n", join(wheres), "\n")
        else
            " "
        end
        string("<", join(generics, ", "), ">", wh)
    end
end

function strsignature(ty::DataType, wrappers::Dict{Type,Wrapper})::String
    if ty <: Tuple
        generics = []

        for ty in ty.types
            push!(generics, strsignature(ty, wrappers))
        end

        name = string("::jlrs::wrappers::inline::tuple::Tuple", length(generics))

        if length(generics) > 0
            return string(name, "<", join(generics, ", "), ">")
        else
            return name
        end
    end

    base = basetype(ty)
    wrapper = wrappers[base]

    name = wrapper.rsname

    generics = []
    if wrapper.framelifetime
        push!(generics, "'frame")
    end

    if wrapper.datalifetime
        push!(generics, "'data")
    end

    for (tparam, param) in zip(wrapper.typeparams, ty.parameters)
        if !tparam.elide
            if param isa TypeVar
                idx = findfirst(a -> a.name == param.name, wrapper.typeparams)
                if idx !== nothing
                    push!(generics, string(param.name))
                end
            elseif param isa DataType
                push!(generics, strsignature(param, wrappers))
            end
        end
    end

    if length(generics) > 0
        string(name, "<", join(generics, ", "), ">")
    else
        name
    end
end

function strsignature(wrapper::StructWrapper, field::Union{StructField,TupleField}, wrappers::Dict{Type,Wrapper})::String
    if field.fieldtype isa GenericWrapper
        return string(field.fieldtype.name)
    elseif field.fieldtype isa TupleWrapper
        return strtuplesignature(wrapper, field, wrappers)
    end

    generics = []

    if field.framelifetime
        push!(generics, "'frame")
    end

    if field.datalifetime
        push!(generics, "'data")
    end

    for (sparam, tparam) in zip(field.fieldtype.typeparams, field.typeparams)
        if !sparam.elide
            if tparam.value isa TypeVar
                idx = findfirst(a -> a.name == tparam.value.name, wrapper.typeparams)
                if idx !== nothing
                    push!(generics, string(tparam.value.name))
                end
            elseif tparam.value isa DataType
                push!(generics, strsignature(tparam.value, wrappers))
            end
        end
    end

    if length(generics) > 0
        string(field.fieldtype.rsname, "<", join(generics, ", "), ">")
    else
        field.fieldtype.rsname
    end
end

function strtuplesignature(wrapper::StructWrapper, field::Union{StructField,TupleField}, wrappers::Dict{Type,Wrapper})::String
    generics = []

    for fieldwrapper in field.fieldtype.fields
        push!(generics, strsignature(wrapper, fieldwrapper, wrappers))
    end

    if length(generics) > 0
        string(field.fieldtype.rsname, "<", join(generics, ", "), ">")
    else
        field.fieldtype.rsname
    end
end

function strstructname(wrapper::StructWrapper)::String
    generics = strgenerics(wrapper)
    if generics !== nothing
        string(wrapper.rsname, generics)
    else
        string(wrapper.rsname, " ")
    end
end

function strstructfield(wrapper::StructWrapper, field::StructField, wrappers::Dict{Type,Wrapper})::String
    if field.fieldtype isa BitsUnionWrapper
        align_field_name = string("_", field.rsname, "_align")
        flag_field_name = string(field.rsname, "_flag")

        ibu, sz, al = Base.uniontype_layout(field.fieldtype.union_of)
        @assert ibu "Not a bits union. This should never happen, please file a bug report."

        alignment = if al == 1
            "::jlrs::wrappers::inline::union::Align1"
        elseif al == 2
            "::jlrs::wrappers::inline::union::Align2"
        elseif al == 4
            "::jlrs::wrappers::inline::union::Align4"
        elseif al == 8
            "::jlrs::wrappers::inline::union::Align8"
        elseif al == 16
            "::jlrs::wrappers::inline::union::Align16"
        else
            error("Unsupported alignment")
        end

        string(
            "    #[jlrs(bits_union_align)]\n",
            "    ", align_field_name, ": ", alignment, ",\n",
            "    #[jlrs(bits_union)]\n",
            "    pub ", field.rsname, ": ::jlrs::wrappers::inline::union::BitsUnion<", sz, ">,\n",
            "    #[jlrs(bits_union_flag)]\n",
            "    pub ", flag_field_name, ": u8,",
        )
    else
        sig = strsignature(wrapper, field, wrappers)
        string("    pub ", field.rsname, ": ", sig, ",")
    end
end

strwrapper(::BuiltinWrapper, ::Dict{Type,Wrapper})::Union{Nothing,String} = nothing

function strwrapper(wrapper::StructWrapper, wrappers::Dict{Type,Wrapper})::Union{Nothing,String}
    ty = getproperty(wrapper.typename.module, wrapper.typename.name)
    isbits = ty isa DataType && findfirst(ty.parameters) do p p isa TypeVar end === nothing && isbitstype(ty)
    intojulia = isbits ? ", IntoJulia" : ""
    zst = isbits && ty.size == 0 ? ", zero_sized_type" : ""

    modname = string(wrapper.typename.module)
    if startswith(modname, "Main.__doctest__")
        modname = "Main"
    end

    parts = [
        "#[repr(C)]",
        string("#[derive(Clone, Debug, Unbox, ValidLayout, Typecheck", intojulia, ")]"),
        string("#[jlrs(julia_type = \"", modname, ".", wrapper.typename.name, "\"", zst, ")]"),
        string("pub struct ", strstructname(wrapper), "{")
    ]
    for field in wrapper.fields
        push!(parts, strstructfield(wrapper, field, wrappers))
    end
    push!(parts, "}")
    join(parts, "\n")
end

"""
    renamestruct!(wrappers::Wrappers, type::Type, rename::String)

Change a struct's name. This can be useful if the name of a struct results in invalid Rust code or
causes warnings.

# Example
```jldoctest
julia> using JlrsReflect

julia> struct Foo end

julia> wrappers = reflect([Foo]);

julia> renamestruct!(wrappers, Foo, "Bar")

julia> wrappers
#[repr(C)]
#[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
#[jlrs(julia_type = "Main.Foo", zero_sized_type)]
pub struct Bar {
}
```
"""
function renamestruct!(wrappers::Wrappers, type::Type, rename::String)::Nothing
    btype::DataType = basetype(type)
    wrappers.dict[btype].rsname = rename

    nothing
end

"""
    renamefields!(wrappers::Wrappers, type::Type, rename::Dict{Symbol,String})
    renamefields!(wrappers::Wrappers, type::Type, rename::Vector{Pair{Symbol,String})

Change some field names of a struct. This can be useful if the name of a struct results in invalid
Rust code or causes warnings.

# Example
```jldoctest
julia> using JlrsReflect

julia> struct Food burger::Bool end

julia> wrappers = reflect([Food]);

julia> renamefields!(wrappers, Food, [:burger => "hamburger"])

julia> wrappers
#[repr(C)]
#[derive(Clone, Debug, Unbox, ValidLayout, Typecheck, IntoJulia)]
#[jlrs(julia_type = "Main.Food")]
pub struct Food {
    pub hamburger: ::jlrs::wrappers::inline::bool::Bool,
}

```
"""
function renamefields! end

function renamefields!(wrappers::Wrappers, type::Type, rename::Dict{Symbol,String})::Nothing
    btype::DataType = basetype(type)
    for field in wrappers.dict[btype].fields
        if field.name in keys(rename)
            field.rsname = rename[field.name]
        end
    end

    nothing
end

function renamefields!(wrappers::Wrappers, type::Type, rename::Vector{Pair{Symbol,String}})::Nothing
    renamefields!(wrappers, type, Dict(rename))
end
end
