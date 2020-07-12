module JlrsReflect

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

struct StructField
    name::Symbol
    rsname::String
    fieldtype::Binding
    typeparams::Vector{TypeParameter}
    referenced::Set{TypeVar}
    framelifetime::Bool
    datalifetime::Bool
end

struct StructBinding <: Binding
    name::Symbol
    rsname::String
    fields::Vector{StructField}
    typeparams::Vector{StructParameter}
    framelifetime::Bool
    datalifetime::Bool
end

struct BuiltinBinding <: Binding
    rsname::String
    typeparams::Vector{StructParameter}
    framelifetime::Bool
    datalifetime::Bool
end

function insertbuiltins!(bindings::Dict{Type, Binding})::Nothing
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
    
    bindings[Any] = BuiltinBinding("jlrs::value::Value", [], true, true)
    bindings[basetype(Array)] = BuiltinBinding("jlrs::value::array::Array", [StructParameter(:T, true), StructParameter(:N, true)], true, true)
    bindings[Core.CodeInstance] = BuiltinBinding("jlrs::value::code_instance::CodeInstance", [], true, true)
    bindings[DataType] = BuiltinBinding("jlrs::value::datatype::DataType", [], true, false)
    bindings[Expr] = BuiltinBinding("jlrs::value::expr::Expr", [], true, false)
    bindings[Method] = BuiltinBinding("jlrs::value::method::Method", [], true, false)
    bindings[Core.MethodInstance] = BuiltinBinding("jlrs::value::method_instance::MethodInstance", [], true, false)
    bindings[Core.MethodTable] = BuiltinBinding("jlrs::value::method_table::MethodTable", [], true, false)
    bindings[Module] = BuiltinBinding("jlrs::value::module::Module", [], true, false)
    bindings[Core.SimpleVector] = BuiltinBinding("jlrs::value::simple_vector::SimpleVector", [], true, false)
    bindings[Core.SSAValue] = BuiltinBinding("jlrs::value::ssa_value::SSAValue", [], true, false)
    bindings[Symbol] = BuiltinBinding("jlrs::value::symbol::Symbol", [], true, false)
    bindings[Task] = BuiltinBinding("jlrs::value::task::Task", [], true, false)
    bindings[Core.TypeName] = BuiltinBinding("jlrs::value::type_name::TypeName", [], true, false)
    bindings[TypeVar] = BuiltinBinding("jlrs::value::type_var::TypeVar", [], true, false)
    bindings[Core.TypeMapEntry] = BuiltinBinding("jlrs::value::typemap_entry::TypeMapEntry", [], true, false)
    bindings[Core.TypeMapLevel] = BuiltinBinding("jlrs::value::typemap_level::TypeMapLevel", [], true, false)
    bindings[Union] = BuiltinBinding("jlrs::value::union::Union", [], true, false)
    bindings[UnionAll] = BuiltinBinding("jlrs::value::union_all::UnionAll", [], true, false)
    bindings[Union{}] = BuiltinBinding("()", [], false, false)

    nothing
end

function toposort!(data::Dict{Type,Set{Type}})::Vector{Type}
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

function partialtype(type::Type)::Union{Nothing,Type}
    if type isa UnionAll
        t = type.body
        while hasproperty(t, :body)
            t = t.body
        end

        return t
    else
        return type    
    end
end

function basetype(type::Type)::Union{Nothing,Type}
    pt = partialtype(type)
    if pt isa Union return pt end
    if pt == Union{} return pt end
    partialtype(getproperty(pt.name.module, pt.name.name))
end

function getdeps!(deps::Dict{Type,Set{Type}}, type::Type)::Nothing
    pt = partialtype(type)
    bt = basetype(type)

    if bt isa Union return end
    if bt == Any return end
    if bt == Union{} return end

    for pparam in pt.parameters
        if pparam isa Type
            getdeps!(deps, pparam)
        end
    end

    if bt in keys(deps) return end
    if bt.abstract return end

    deps[bt] = Set()

    for ty in fieldtypes(bt)
        if ty isa Type
            fieldbt = basetype(ty)
            push!(deps[bt], fieldbt)
            getdeps!(deps, ty)
        end
    end

    nothing
end

function extractparams(ty::Type, bindings::Dict{Type, Binding})::Set{TypeVar}
    out = Set()
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

function isbitsunion(u::Union)::Bool
    a = if u.a isa Union
        isbitsunion(u.a)
    else
        isbitstype(u.a)
    end

    b = if u.b isa Union
        isbitsunion(u.b)
    else
        isbitstype(u.b)
    end

    a && b
end

function structfield(fieldname::Symbol, fieldtype::Union{Type,TypeVar}, bindings::Dict{Type, Binding})
    if fieldtype isa TypeVar
        StructField(fieldname, string(fieldname), GenericBinding(fieldtype.name), [TypeParameter(fieldtype.name, fieldtype)], Set([fieldtype]), false, false)
    elseif fieldtype isa UnionAll
        bt = basetype(fieldtype)
        
        if bt.name.name == :Array
            fieldbinding = bindings[bt]
            tparams = map(a -> TypeParameter(a[1].name, a[2]), zip(bt.parameters, bt.parameters))
            references = extractparams(bt, bindings)
            StructField(fieldname, string(fieldname), fieldbinding, tparams, references, fieldbinding.framelifetime, fieldbinding.datalifetime)
        else
            StructField(fieldname, string(fieldname), bindings[Any], [], Set(), true, true)
        end
    elseif fieldtype isa Union
        if isbitsunion(fieldtype)
            throw(ErrorException("Bits unions are not supported"))
        else
            StructField(fieldname, string(fieldname), bindings[Any], [], Set(), true, true)
        end
    elseif fieldtype == Union{}
        StructField(fieldname, string(fieldname), bindings[Union{}], [], Set(), false, false)
    elseif fieldtype <: Tuple
        params = extractparams(fieldtype, bindings)
        if length(params) > 0
            # Todo
        elseif fieldtype.isconcretetype
            # Todo
        else
            StructField(fieldname, string(fieldname), bindings[Any], [], Set(), true, true)
        end
    elseif fieldtype isa DataType
        bt = basetype(fieldtype)
        if !fieldtype.isinlinealloc && !fieldtype.hasfreetypevars !(bindings[bt] isa BuiltinBinding)
            StructField(fieldname, string(fieldname), bindings[Any], [], Set(), true, true)
        else
            fieldbinding = bindings[bt]
            tparams = map(a -> TypeParameter(a[1].name, a[2]), zip(bt.parameters, fieldtype.parameters))
            references = extractparams(fieldtype, bindings)
            StructField(fieldname, string(fieldname), fieldbinding, tparams, references, fieldbinding.framelifetime, fieldbinding.datalifetime)
        end
    end
end

function createbinding!(bindings::Dict{Type, Binding}, type::Type)::Nothing
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
    bindings[bt] = StructBinding(type.name.name, string(type.name.name), fields, params, framelifetime, datalifetime)
    nothing
end

function reflect(types::Vector{Type})
    deps = Dict{Type,Set{Type}}()
    for ty in types
        getdeps!(deps, ty)
    end

    bindings = Dict{Type, Binding}()
    insertbuiltins!(bindings)

    for ty in toposort!(deps)
        createbinding!(bindings, ty)
    end

    names = []
    for name in keys(bindings)
        push!(names, name)
    end
    sort!(names, lt=(a, b) -> string(a) < string(b))

    for name in names
        rustimpl = strbinding(bindings[name], bindings)
        if rustimpl !== nothing
            println(rustimpl)
            println()
        end
    end
end

function strgenerics(binding::StructBinding)::Union{Nothing, String}
    generics = []
    if binding.framelifetime
        push!(generics, "'frame")
    end

    if binding.datalifetime
        push!(generics, "'data")
    end

    for param in binding.typeparams
        if !param.elide
            push!(generics, string(param.name))
        end
    end

    if length(generics) > 0
        string("<", join(generics, ", "), ">")
    end
end

function strgenerics(binding::StructBinding, field::StructField, bindings::Dict{Type, Binding})::Union{Nothing, String}
    generics = []
    fieldbinding = field.fieldtype

    if fieldbinding.framelifetime
        push!(generics, "'frame")
    end

    if fieldbinding.datalifetime
        push!(generics, "'data")
    end

    for param in binding.typeparams
        if !param.elide
            push!(generics, string(param.name))
        end
    end

    if length(generics) > 0
        string("<", join(generics, ", "), ">")
    end
end

function strsignature(ty::DataType, bindings::Dict{Type, Binding})::String
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

    for param in ty.parameters
        if param isa TypeVar
            idx = findfirst(a -> a.name == param.name, binding.typeparams)
            if idx !== nothing
                push!(generics, string(param.name))
            end
        elseif param isa DataType
            push!(generics, strsignature(param, bindings))
        end
    end

    if length(generics) > 0
        string(name, "<", join(generics, ", "), ">")
    else
        name
    end
end

function strsignature(binding::StructBinding, field::StructField, bindings::Dict{Type, Binding})::String
    if field.fieldtype isa GenericBinding
        return string(field.fieldtype.name)
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

function strstructname(binding::StructBinding)::String
    generics = strgenerics(binding)
    if generics !== nothing
        string(binding.rsname, generics)
    else
        binding.rsname
    end
end

function strfieldtype(binding::StructBinding, field::StructField, bindings::Dict{Type, Binding})::String
    if field.fieldtype isa StructBinding
        generics = strgenerics(binding, field, bindings)
        if length(generics > 0)
            string(field.fieldtype.rsname, generics)
        else
            field.fieldtype.rsname
        end
    else
        field.fieldtype.name
    end
end

function strstructfield(binding::StructBinding, field::StructField, bindings::Dict{Type, Binding})::String
    sig = strsignature(binding, field, bindings)
    string("    ", field.rsname, ": ", sig, ",")
end

function strbinding(binding::BuiltinBinding, bindings)::Union{Nothing, String}

end

function strbinding(binding::StructBinding, bindings::Dict{Type, Binding})::Union{Nothing, String}
    parts = ["#[repr(C)]", string("struct ", strstructname(binding), " {")]
    for field in binding.fields
        push!(parts, strstructfield(binding, field, bindings))
    end
    push!(parts, "}")
    join(parts, "\n")
end

struct A{N,U}
    a::U
end

struct B{T}
    b::A{2,T}
end

struct C 
    i::B{A{7,B{Int}}}
end

struct D{T}
    x::A{N, T} where N
end

mutable struct E
    i::Real
end

struct F
    e::E
end

reflect([A, B, C, D, E, F])
end
