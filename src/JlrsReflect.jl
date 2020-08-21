module JlrsReflect

export reflect, renamestruct!, renamefields!

import Base: show, getindex, write

abstract type Binding end

struct StructParameter
    name::Symbol
    elide::Bool
end

struct TypeParameter
    name::Symbol
    value
end

struct GenericBinding <: Binding
    name::Symbol
end

mutable struct StructField
    name::Symbol
    rsname::String
    fieldtype::Binding
    typeparams::Vector{TypeParameter}
    referenced::Set{TypeVar}
    framelifetime::Bool
    datalifetime::Bool
end

struct BitsUnionBinding <: Binding
    union_of::Union
    typeparams::Vector{StructParameter}
    framelifetime::Bool
    datalifetime::Bool
end

mutable struct StructBinding <: Binding
    name::Symbol
    typename::Core.TypeName
    rsname::String
    fields::Vector{StructField}
    typeparams::Vector{StructParameter}
    framelifetime::Bool
    datalifetime::Bool
end

struct TupleField
    fieldtype::Binding
    typeparams::Vector{TypeParameter}
    framelifetime::Bool
    datalifetime::Bool
end

struct TupleBinding <: Binding
    rsname::String
    fields::Vector{TupleField}
    framelifetime::Bool
    datalifetime::Bool
    TupleBinding(fields::Vector{TupleField}, framelifetime::Bool, datalifetime::Bool) = new(string("::jlrs::value::tuple::Tuple", length(fields)), fields, framelifetime, datalifetime)
end

struct BuiltinBinding <: Binding
    rsname::String
    typeparams::Vector{StructParameter}
    framelifetime::Bool
    datalifetime::Bool
end

struct Bindings
    bindings::Dict{Type,Binding}
end

struct StringBindings
    bindings::Dict{Type,String}
end

function StringBindings(bindings::Bindings)
    strbindings = Dict{Type,String}()
    names = []

    for name in keys(bindings.bindings)
        rustimpl = strbinding(bindings.bindings[name], bindings.bindings)
        if rustimpl !== nothing
            strbindings[name] = rustimpl
        end
    end

    StringBindings(strbindings)
end

function getindex(sb::StringBindings, els...)
    sb.bindings[els...]
end

function show(io::IO, bindings::Bindings)
    rustimpls = []
    names = []

    for name in keys(bindings.bindings)
        push!(names, name)
    end

    for name in sort(names, lt=(a, b) -> string(a) < string(b))
        rustimpl = strbinding(bindings.bindings[name], bindings.bindings)
        if rustimpl !== nothing
            push!(rustimpls, rustimpl)
        end
    end

    print(io, join(rustimpls, "\n\n"))
end

function write(io::IO, bindings::Bindings)
    rustimpls = ["use jlrs::prelude::*;"]
    names = []

    for name in keys(bindings.bindings)
        push!(names, name)
    end

    for name in sort(names, lt=(a, b) -> string(a) < string(b))
        rustimpl = strbinding(bindings.bindings[name], bindings.bindings)
        if rustimpl !== nothing
            push!(rustimpls, rustimpl)
        end
    end

    write(io, join(rustimpls, "\n\n"), "\n")
end

function insertbuiltins!(bindings::Dict{Type,Binding})::Nothing
    bindings[UInt8] = BuiltinBinding("u8", [], false, false)
    bindings[UInt16] = BuiltinBinding("u16", [], false, false)
    bindings[UInt32] = BuiltinBinding("u32", [], false, false)
    bindings[UInt64] = BuiltinBinding("u64", [], false, false)
    bindings[Int8] = BuiltinBinding("i8", [], false, false)
    bindings[Int16] = BuiltinBinding("i16", [], false, false)
    bindings[Int32] = BuiltinBinding("i32", [], false, false)
    bindings[Int64] = BuiltinBinding("i64", [], false, false)
    bindings[Float32] = BuiltinBinding("f32", [], false, false)
    bindings[Float64] = BuiltinBinding("f64", [], false, false)
    bindings[Bool] = BuiltinBinding("bool", [], false, false)
    bindings[Char] = BuiltinBinding("char", [], false, false)

    bindings[Any] = BuiltinBinding("::jlrs::value::Value", [], true, true)
    bindings[basetype(Array)] = BuiltinBinding("::jlrs::value::array::Array", [StructParameter(:T, true), StructParameter(:N, true)], true, true)
    bindings[Core.CodeInstance] = BuiltinBinding("::jlrs::value::code_instance::CodeInstance", [], true, false)
    bindings[DataType] = BuiltinBinding("::jlrs::value::datatype::DataType", [], true, false)
    bindings[Expr] = BuiltinBinding("::jlrs::value::expr::Expr", [], true, false)
    bindings[String] = BuiltinBinding("::jlrs::value::string::JuliaString", [], true, false)
    bindings[Method] = BuiltinBinding("::jlrs::value::method::Method", [], true, false)
    bindings[Core.MethodInstance] = BuiltinBinding("::jlrs::value::method_instance::MethodInstance", [], true, false)
    bindings[Core.MethodTable] = BuiltinBinding("::jlrs::value::method_table::MethodTable", [], true, false)
    bindings[Module] = BuiltinBinding("::jlrs::value::module::Module", [], true, false)
    bindings[Core.SimpleVector] = BuiltinBinding("::jlrs::value::simple_vector::SimpleVector", [], true, false)
    bindings[Symbol] = BuiltinBinding("::jlrs::value::symbol::Symbol", [], true, false)
    bindings[Task] = BuiltinBinding("::jlrs::value::task::Task", [], true, false)
    bindings[Core.TypeName] = BuiltinBinding("::jlrs::value::type_name::TypeName", [], true, false)
    bindings[TypeVar] = BuiltinBinding("::jlrs::value::type_var::TypeVar", [], true, false)
    bindings[Core.TypeMapEntry] = BuiltinBinding("::jlrs::value::typemap_entry::TypeMapEntry", [], true, false)
    bindings[Core.TypeMapLevel] = BuiltinBinding("::jlrs::value::typemap_level::TypeMapLevel", [], true, false)
    bindings[Union] = BuiltinBinding("::jlrs::value::union::Union", [], true, false)
    bindings[UnionAll] = BuiltinBinding("::jlrs::value::union_all::UnionAll", [], true, false)

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
    d = Dict{Type,Binding}()
    insertbuiltins!(d)
    d
end

function isnonparametric(type::Union)::Bool
    for utype in Base.uniontypes(type)
        if utype isa DataType
            if utype.hasfreetypevars
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
                if !ttype.isconcretetype
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
        elseif type.abstract
            return
        end

        partial = partialtype(type)
        base = basetype(type)

        if !(base in keys(acc)) && !(base in keys(BUILTINS) )
            acc[base] = Set()

            for btype in base.types
                if btype isa DataType
                    if btype <: Tuple
                        if btype.hasfreetypevars
                            error("Tuple fields with type parameters are not supported")
                        elseif !btype.isconcretetype
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

function extractparams(ty::Type, bindings::Dict{Type,Binding})::Set{TypeVar}
    out = Set()
    if ty <: Tuple
        for elty in ty.parameters
            union!(out, extractparams(elty, bindings))
        end

        return out
    elseif ty isa Union
        return out
    elseif ty.abstract
        return out
    end

    partial = partialtype(ty)
    base = basetype(ty)

    binding = bindings[base]

    if !hasproperty(partial, :parameters)
        return out
    end

    for (name, param) in zip(binding.typeparams, partial.parameters)
        if !name.elide
            if param isa TypeVar
                idx = findfirst(t -> t.name == name.name, binding.typeparams)
                if idx !== nothing
                    push!(out, param)
                end
            elseif param isa Type
                union!(out, extractparams(param, bindings))
            end
        end
    end

    out
end

function concretetuplefield(tuple::Type, bindings::Dict{Type,Binding})::TupleBinding
    framelifetime = false
    datalifetime = false
    fieldbindings::Vector{TupleField} = []

    for ty in tuple.types
        fieldbinding = if ty isa DataType
            if ty.isinlinealloc
                if ty <: Tuple
                    b = concretetuplefield(ty, bindings)
                    framelifetime |= b.framelifetime
                    datalifetime |= b.datalifetime
                    TupleField(b, [], b.framelifetime, b.datalifetime)
                else
                    bty = basetype(ty)
                    b = bindings[bty]
                    tparams = map(a -> TypeParameter(a[1].name, a[2]), zip(bty.parameters, ty.parameters))
                    framelifetime |= b.framelifetime
                    datalifetime |= b.datalifetime
                    TupleField(b, tparams, b.framelifetime, b.datalifetime)
                end
            elseif ty in keys(bindings)
                b = bindings[ty]
                if b isa BuiltinBinding
                    framelifetime |= b.framelifetime
                    datalifetime |= b.datalifetime
                    TupleField(b, [], b.framelifetime, b.datalifetime)
                else
                    framelifetime = true
                    datalifetime = true
                    TupleField(bindings[Any], [], true, true)
                end
            else
                framelifetime = true
                datalifetime = true
                TupleField(bindings[Any], [], true, true)
            end
        else
            error("Invalid type")
        end

        push!(fieldbindings, fieldbinding)
    end

    TupleBinding(fieldbindings, framelifetime, datalifetime)
end


function structfield(fieldname::Symbol, fieldtype::Union{Type,TypeVar}, bindings::Dict{Type,Binding})::StructField
    if fieldtype isa TypeVar
        StructField(fieldname, string(fieldname), GenericBinding(fieldtype.name), [TypeParameter(fieldtype.name, fieldtype)], Set([fieldtype]), false, false)
    elseif fieldtype isa UnionAll
        bt = basetype(fieldtype)

        if bt isa Union
            error("Unions with type parameters are not supported")
        elseif bt.name.name == :Array
            fieldbinding = bindings[bt]
            tparams = map(a -> TypeParameter(a[1].name, a[2]), zip(bt.parameters, bt.parameters))
            references = extractparams(bt, bindings)
            StructField(fieldname, string(fieldname), fieldbinding, tparams, references, fieldbinding.framelifetime, fieldbinding.datalifetime)
        else
            StructField(fieldname, string(fieldname), bindings[Any], [], Set(), true, true)
        end
    elseif fieldtype isa Union
        if Base.isbitsunion(fieldtype)
            StructField(fieldname, string(fieldname), BitsUnionBinding(fieldtype, [], false, false), [], Set(), false, false)
        else
            StructField(fieldname, string(fieldname), bindings[Any], [], Set(), true, true)
        end
    elseif fieldtype == Union{}
        StructField(fieldname, string(fieldname), bindings[Union{}], [], Set(), false, false)
    elseif fieldtype <: Tuple
        params = extractparams(fieldtype, bindings)
        if length(params) > 0
            error("Tuples with type parameters are not supported")
        elseif fieldtype.isconcretetype
            binding = concretetuplefield(fieldtype, bindings)
            StructField(fieldname, string(fieldname), binding, [], Set(), binding.framelifetime, binding.datalifetime)
        else
            StructField(fieldname, string(fieldname), bindings[Any], [], Set(), true, true)
        end
    elseif fieldtype isa DataType
        bt = basetype(fieldtype)
        if bt in keys(bindings)
            fieldbinding = bindings[bt]
            tparams = map(a -> TypeParameter(a[1].name, a[2]), zip(bt.parameters, fieldtype.parameters))
            references = extractparams(fieldtype, bindings)
            StructField(fieldname, string(fieldname), fieldbinding, tparams, references, fieldbinding.framelifetime, fieldbinding.datalifetime)
        elseif !fieldtype.isinlinealloc
            StructField(fieldname, string(fieldname), bindings[Any], [], Set(), true, true)
        else
            error("Cannot create field binding")
        end
    else
        error("Unknown field type")
    end
end

function createbinding!(bindings::Dict{Type,Binding}, type::Type)::Nothing
    bt = basetype(type)

    if bt in keys(bindings) return end
    if bt.abstract
        bindings[bt] = bindings[Any]
        return
    end

    fields = []
    framelifetime = false
    datalifetime = false
    typevars = Set()
    for (fieldname, fieldtype) in zip(fieldnames(bt), fieldtypes(bt))
        field = structfield(fieldname, fieldtype, bindings)
        framelifetime |= field.framelifetime
        datalifetime |= field.datalifetime
        union!(typevars, field.referenced)
        push!(fields, field)
    end

    params = map(a -> StructParameter(a.name, !(a in typevars)), bt.parameters)
    bindings[bt] = StructBinding(type.name.name, type.name, string(type.name.name), fields, params, framelifetime, datalifetime)
    nothing
end

function haslifetimes(ty::Type, bindings::Dict{Type,JlrsReflect.Binding})::Tuple{Bool,Bool}
    framelifetime = false

    if ty <: Tuple
        if ty.isconcretetype
            for fty in ty.types
                framelt, datalt = haslifetimes(fty, bindings)
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
        binding = bindings[bt]

        if binding.datalifetime
            return (true, true)
        end

        framelifetime |= binding.framelifetime

        if binding isa StructBinding
            for param in ty.parameters
                if param isa Type
                    framelt, datalt = haslifetimes(param, bindings)
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

function setparamlifetimes!(bindings::Dict{Type,JlrsReflect.Binding})::Nothing
    for (ty, binding) in bindings
        if binding isa StructBinding
            framelifetime = binding.framelifetime
            datalifetime = binding.datalifetime

            if datalifetime
                continue
            end

            for field in binding.fields
                for param in field.typeparams
                    if param.value !== nothing && !(param.value isa TypeVar)
                        framelt, datalt = haslifetimes(param.value, bindings)
                        if datalt
                            framelifetime = true
                            datalifetime = true
                            break
                        end

                        framelifetime |= framelt
                    end
                end

                if binding.datalifetime
                    break
                end
            end

            binding.framelifetime = framelifetime
            binding.datalifetime = datalifetime
        end
    end

    nothing
end

"""
    reflect(types::Vector{<:Type})::Bindings

Generate Rust mappings for all types in `types` and their dependencies. The only requirement is
that these types must not contain any union or tuple fields that depend on a free type parameter.
Bindings are generated for the most general case by erasing the contents of all provided
parameters, so you can't avoid this restriction by explicitly trying to avoid this restriction by
providing a more qualified type. The only effect qualifying types has, is that bindings to these
types will also be generated. The mappings will derive `JuliaStruct`, and `IntoJulia` if it's a
bits type (with no free type parameters).

The result of this method can be written to a file, its contents will normally be a valid Rust
module.

When you use these mappings with jlrs, these types must be available with the same path. For
example, if you generate bindings for `Main.Bar.Baz`, this type must be available through that
exact path and not some other path like `Main.Foo.Bar.Baz`.

Bits unions are turned into three fields for size and alignment requirement purposes. Besides a
field with the same name that contains the raw data, a private field that enforces the proper
alignment named `_{fieldname}_align` and a public field named `{fieldname}_flag` that contains the
flag that indicates the active variant will be generated.

# Example
```jldoctest
julia> using JlrsReflect

julia> reflect([StackTraces.StackFrame])
#[repr(C)]
#[jlrs(julia_type = "Base.StackTraces.StackFrame")]
#[derive(Copy, Clone, Debug, JuliaStruct)]
pub struct StackFrame<'frame, 'data> {
    pub func: ::jlrs::value::symbol::Symbol<'frame>,
    pub file: ::jlrs::value::symbol::Symbol<'frame>,
    pub line: i64,
    pub linfo: ::jlrs::value::Value<'frame, 'data>,
    pub from_c: bool,
    pub inlined: bool,
    pub pointer: u64,
}

#[repr(C)]
#[jlrs(julia_type = "Core.CodeInfo")]
#[derive(Copy, Clone, Debug, JuliaStruct)]
pub struct CodeInfo<'frame, 'data> {
    pub code: ::jlrs::value::array::Array<'frame, 'data>,
    pub codelocs: ::jlrs::value::Value<'frame, 'data>,
    pub ssavaluetypes: ::jlrs::value::Value<'frame, 'data>,
    pub ssaflags: ::jlrs::value::array::Array<'frame, 'data>,
    pub method_for_inference_limit_heuristics: ::jlrs::value::Value<'frame, 'data>,
    pub linetable: ::jlrs::value::Value<'frame, 'data>,
    pub slotnames: ::jlrs::value::array::Array<'frame, 'data>,
    pub slotflags: ::jlrs::value::array::Array<'frame, 'data>,
    pub slottypes: ::jlrs::value::Value<'frame, 'data>,
    pub rettype: ::jlrs::value::Value<'frame, 'data>,
    pub parent: ::jlrs::value::Value<'frame, 'data>,
    pub edges: ::jlrs::value::Value<'frame, 'data>,
    pub min_world: u64,
    pub max_world: u64,
    pub inferred: bool,
    pub inlineable: bool,
    pub propagate_inbounds: bool,
    pub pure: bool,
}

#[repr(C)]
#[jlrs(julia_type = "Core.Nothing")]
#[derive(Copy, Clone, Debug, JuliaStruct)]
pub struct Nothing {
}
```
"""
function reflect(types::Vector{<:Type})::Bindings
    deps = Dict{DataType,Set{DataType}}()
    for ty in types
        extractdeps!(deps, ty)
    end

    bindings = Dict{Type,Binding}()
    insertbuiltins!(bindings)

    for ty in toposort!(deps)
        createbinding!(bindings, ty)
    end

    setparamlifetimes!(bindings)
    Bindings(bindings)
end

function strgenerics(binding::StructBinding)::Union{Nothing,String}
    generics = []
    wheres = []
    if binding.framelifetime
        push!(generics, "'frame")
    end

    if binding.datalifetime
        push!(generics, "'data")
    end

    for param in binding.typeparams
        if !param.elide
            push!(generics, string(param.name))
            push!(wheres, string("    ", param.name, ": ::jlrs::traits::ValidLayout + Copy,"))
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

function strsignature(ty::DataType, bindings::Dict{Type,Binding})::String
    if ty <: Tuple
        generics = []

        for ty in ty.types
            push!(generics, strsignature(ty, bindings))
        end

        name = string("::jlrs::value::tuple::Tuple", length(generics))

        if length(generics) > 0
            return string(name, "<", join(generics, ", "), ">")
        else
            return name
        end
    end

    base = basetype(ty)
    binding = bindings[base]

    name = binding.rsname

    generics = []
    if binding.framelifetime
        push!(generics, "'frame")
    end

    if binding.datalifetime
        push!(generics, "'data")
    end

    for (tparam, param) in zip(binding.typeparams, ty.parameters)
        if !tparam.elide
            if param isa TypeVar
                idx = findfirst(a -> a.name == param.name, binding.typeparams)
                if idx !== nothing
                    push!(generics, string(param.name))
                end
            elseif param isa DataType
                push!(generics, strsignature(param, bindings))
            end
        end
    end

    if length(generics) > 0
        string(name, "<", join(generics, ", "), ">")
    else
        name
    end
end

function strsignature(binding::StructBinding, field::Union{StructField,TupleField}, bindings::Dict{Type,Binding})::String
    if field.fieldtype isa GenericBinding
        return string(field.fieldtype.name)
    elseif field.fieldtype isa TupleBinding
        return strtuplesignature(binding, field, bindings)
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
                idx = findfirst(a -> a.name == tparam.value.name, binding.typeparams)
                if idx !== nothing
                    push!(generics, string(tparam.value.name))
                end
            elseif tparam.value isa DataType
                push!(generics, strsignature(tparam.value, bindings))
            end
        end
    end

    if length(generics) > 0
        string(field.fieldtype.rsname, "<", join(generics, ", "), ">")
    else
        field.fieldtype.rsname
    end
end

function strtuplesignature(binding::StructBinding, field::Union{StructField,TupleField}, bindings::Dict{Type,Binding})::String
    generics = []

    for fieldbinding in field.fieldtype.fields
        push!(generics, strsignature(binding, fieldbinding, bindings))
    end

    if length(generics) > 0
        string(field.fieldtype.rsname, "<", join(generics, ", "), ">")
    else
        field.fieldtype.rsname
    end
end

function strstructname(binding::StructBinding)::String
    generics = strgenerics(binding)
    if generics !== nothing
        string(binding.rsname, generics)
    else
        string(binding.rsname, " ")
    end
end

function strstructfield(binding::StructBinding, field::StructField, bindings::Dict{Type,Binding})::String
    if field.fieldtype isa BitsUnionBinding
        align_field_name = string("_", field.rsname, "_align")
        flag_field_name = string(field.rsname, "_flag")

        sz = 0
        al = 0
        for ty in Base.uniontypes(field.fieldtype.union_of)
            sz = max(sz, sizeof(ty))
            al = max(al, Base.datatype_alignment(ty))
        end

        alignment = if al == 1
            "::jlrs::value::union::Align1"
        elseif al == 2
            "::jlrs::value::union::Align2"
        elseif al == 4
            "::jlrs::value::union::Align4"
        elseif al == 8
            "::jlrs::value::union::Align8"
        elseif al == 16
            "::jlrs::value::union::Align16"
        else
            error("Unsupported alignment")
        end

        string(
            "    #[jlrs(bits_union_align)]\n",
            "    ", align_field_name, ": ", alignment, ",\n",
            "    #[jlrs(bits_union)]\n",
            "    pub ", field.rsname, ": ::jlrs::value::union::BitsUnion<[::std::mem::MaybeUninit<u8>; ", sz, "]>,\n",
            "    #[jlrs(bits_union_flag)]\n",
            "    pub ", flag_field_name, ": u8,",
        )
    else
        sig = strsignature(binding, field, bindings)
        string("    pub ", field.rsname, ": ", sig, ",")
    end
end

strbinding(::BuiltinBinding, ::Dict{Type,Binding})::Union{Nothing,String} = nothing

function strbinding(binding::StructBinding, bindings::Dict{Type,Binding})::Union{Nothing,String}
    ty = getproperty(binding.typename.module, binding.typename.name)
    isbits = ty isa DataType && !ty.hasfreetypevars && ty.isbitstype && length(ty.types) > 0 ? ", IntoJulia" : ""

    parts = [
        "#[repr(C)]",
        string("#[jlrs(julia_type = \"", binding.typename.module, ".", binding.typename.name, "\")]"),
        string("#[derive(Copy, Clone, Debug, JuliaStruct", isbits, ")]"),
        string("pub struct ", strstructname(binding), "{")
    ]
    for field in binding.fields
        push!(parts, strstructfield(binding, field, bindings))
    end
    push!(parts, "}")
    join(parts, "\n")
end

"""
    renamestruct!(bindings::Bindings, type::Type, rename::String)

Change a struct's name. This can be useful if the name of a struct results in invalid Rust code or
causes warnings.

# Example
```jldoctest
julia> using JlrsReflect

julia> struct Foo end;

julia> bindings = reflect([Foo]);

julia> renamestruct!(bindings, Foo, "Bar")

julia> bindings
#[repr(C)]
#[jlrs(julia_type = "Main.Foo")]
#[derive(Copy, Clone, Debug, JuliaStruct)]
pub struct Bar {
}
```
"""
function renamestruct!(bindings::Bindings, type::Type, rename::String)::Nothing
    btype::DataType = basetype(type)
    bindings.bindings[btype].rsname = rename

    nothing
end

"""
    renamefields!(bindings::Bindings, type::Type, rename::Dict{Symbol,String})
    renamefields!(bindings::Bindings, type::Type, rename::Vector{Pair{Symbol,String})

Change some field names of a struct. This can be useful if the name of a struct results in invalid
Rust code or causes warnings.

# Example
```jldoctest
julia> using JlrsReflect

julia> struct Food
    🍔::Bool
end;

julia> bindings = reflect([Food]);

julia> renamefields!(bindings, Food, [:🍔 => "burger"])

julia> bindings
#[repr(C)]
#[jlrs(julia_type = "Main.Foo")]
#[derive(Copy, Clone, Debug, JuliaStruct)]
pub struct Food {
    burger: bool
}
```
"""
function renamefields! end

function renamefields!(bindings::Bindings, type::Type, rename::Dict{Symbol,String})::Nothing
    btype::DataType = basetype(type)
    for field in bindings.bindings[btype].fields
        if field.name in keys(rename)
            field.rsname = rename[field.name]
        end
    end

    nothing
end

function renamefields!(bindings::Bindings, type::Type, rename::Vector{Pair{Symbol,String}})::Nothing
    renamefields!(bindings, type, Dict(rename))
end
end
