module JlrsReflect

JuliaType = Union{DataType,UnionAll,Union}
TypeDict = Dict{JuliaType,Set{JuliaType}}

struct TypeParameter
    name::Symbol
    value
end

abstract type Binding end

struct BuiltinBinding <: Binding
    jlname::Symbol
    rsname::String
    framelifetime::Bool
    datalifetime::Bool
    typeparams::Vector{TypeParameter}
end

struct GenericBinding <: Binding
    jlname::Symbol
    rsname::String
    typeparam::TypeParameter
end

struct StructField
    jlname::Symbol
    rsname::String
    binding::Binding
    typeparams::Vector{TypeParameter}
    unionall::Bool
end

struct StructBinding <: Binding
    jlname::Symbol
    rsname::String
    mod::Module
    framelifetime::Bool
    datalifetime::Bool
    typeparams::Vector{TypeParameter}
    fields::Vector{StructField}
end

struct TupleBinding <: Binding
    fields::Vector{Binding}
end

function structfield(ty::Type, jlname::Symbol, ft::Type, generated::Dict, rename::Dict)
    rsname = if jlname in keys(rename)
        rename[jlname]
    else
        string(jlname)
    end

    pt = partialtype(ft)
    bt = basetype(ft)
    binding = generated[bt]

    tparams = []
    unionall = false

    for (base, partial) in zip(bt.parameters, pt.parameters)
        if partial isa TypeVar 
            if partial in ty.parameters
                x = findfirst(tp -> tp.name == base.name, binding.typeparams)

                if x !== nothing
                    if partial.name isa Core.TypeName
                        push!(tparams, TypeParameter(partial.name.name, pt.parameters[x]))
                    else
                        push!(tparams, TypeParameter(partial.name, pt.parameters[x]))
                    end
                end
            else
                unionall = true
                tparams = []
                binding = generated[Any]
                break
            end
        elseif partial isa DataType
            x = findfirst(tp -> tp.name == base.name, binding.typeparams)

            if x !== nothing
                if partial.name isa Core.TypeName
                    push!(tparams, TypeParameter(partial.name.name, pt.parameters[x]))
                else
                    push!(tparams, TypeParameter(partial.name, pt.parameters[x]))
                end
            end
        end
    end

    StructField(jlname, rsname, binding, tparams, unionall)
end

function structfield(ty::Type, jlname::Symbol, ft::TypeVar, generated::Dict, rename::Dict)
rsname = if jlname in keys(rename)
    rename[jlname]
    else
        string(jlname)
    end

    binding = GenericBinding(ft.name, string(ft.name), TypeParameter(ft.name, nothing))
    StructField(jlname, rsname, binding, [TypeParameter(ft.name, nothing)], false)
end

function needslifetimes(tp::TypeParameter)
    if tp.value isa DataType
        return !isbitstype(tp.value)
    end

    return false
end

function structfields(ty::Type, generated::Dict, rename::Dict)
    println("Generating for $ty")
    framelifetime = false
    datalifetime = false
    fields::Vector{StructField} = []

    tparamsset = Set()

    for (name, fieldtype) in zip(fieldnames(ty), fieldtypes(ty))
        field = structfield(ty, name, fieldtype, generated, rename)

        if fieldtype isa TypeVar
            push!(tparamsset, fieldtype.name)
        elseif length(field.typeparams) > 0
            for tp in field.typeparams
                push!(tparamsset, tp.name)
            end
        end

        if hasproperty(field.binding, :framelifetime)
            framelifetime |= field.binding.framelifetime
            datalifetime |= field.binding.datalifetime

            for param in field.typeparams
                lt = needslifetimes(param)
                framelifetime |= lt
                datalifetime |= lt
            end
        end

        push!(fields, field)
    end

    tparams = []

    for t in ty.parameters
        if t.name in tparamsset
            push!(tparams, TypeParameter(t.name, nothing))
        end
    end

    (framelifetime, datalifetime, tparams, fields)
end

function structbinding(typ::DataType, generated, rename::Dict)
    jlname = typ.name.name
    (rsname, renamedfields) = if typ in keys(rename)
        rename[typ]
    else
        string(jlname), Dict()
    end

    mod = typ.name.module
    (framelifetime, datalifetime, typeparams, fields) = structfields(typ, generated, renamedfields)
    StructBinding(jlname, rsname, mod, framelifetime, datalifetime, typeparams, fields)
end

function getdeps!(out::TypeDict, type::Type, generated)
    if type in keys(out) return end
    if type in keys(generated) return end

    try
        ftset = Set(fieldtypes(type))
        out[type] = ftset

        for ty in ftset
            if ty isa DataType || ty isa Union
                getdeps!(out, ty, generated)
            end
        end
    catch
        out[type] = Set()
    end
end

function toposort!(data::Dict{T,Set{T}}) where T
    for (k, v) in data
        delete!(v, k)
    end

    for item in setdiff(reduce(∪, values(data)), keys(data))
        data[item] = Set{T}()
    end
    
    rst = Vector{T}()
    while true
        ordered = Set(item for (item, dep) in data if isempty(dep))
        if isempty(ordered) break end
        append!(rst, ordered)
        data = Dict{T,Set{T}}(item => setdiff(dep, ordered) for (item, dep) in data if item ∉ ordered)
    end
    
    @assert isempty(data) "a cyclic dependency exists amongst $(keys(data))"
    rst
end

function getdeps(types::Vector{<:Type}, generated)::TypeDict
    out = TypeDict()
    
    for type in types
        getdeps!(out, type, generated)
    end

    out
end

# if type is a UnionAll, the DataType at the bottom is returned 
# if type is a DataType, the same DataType is returned 
function partialtype(type::Type)
    if type isa UnionAll
        ty = type.body
        while hasproperty(ty, :body)
            ty = ty.body
        end

        ty
    else
        type
    end
end

# Returns the partial type with all type parameters cleared
function basetype(type::Type)::Union{DataType,Nothing}
    ty = partialtype(type)
    partialtype(getproperty(ty.name.module, ty.name.name))
end

function generatedbindings()
    generated = Dict()

    generated[Nothing] = BuiltinBinding(:Nothing, "()", false, false, [])
    
    # Primitives
    generated[UInt8] = BuiltinBinding(UInt8.name.name, "u8", false, false, [])
    generated[UInt8] = BuiltinBinding(UInt8.name.name, "u8", false, false, [])
    generated[UInt16] = BuiltinBinding(UInt16.name.name, "u16", false, false, [])
    generated[UInt32] = BuiltinBinding(UInt32.name.name, "u32", false, false, [])
    generated[UInt64] = BuiltinBinding(UInt64.name.name, "u64", false, false, [])
    generated[Int8] = BuiltinBinding(Int8.name.name, "i8", false, false, [])
    generated[Int16] = BuiltinBinding(Int16.name.name, "i16", false, false, [])
    generated[Int32] = BuiltinBinding(Int32.name.name, "i32", false, false, [])
    generated[Int64] = BuiltinBinding(Int64.name.name, "i64", false, false, [])
    generated[Float32] = BuiltinBinding(Float32.name.name, "f32", false, false, [])
    generated[Float64] = BuiltinBinding(Float64.name.name, "f64", false, false, [])
    generated[Bool] = BuiltinBinding(Bool.name.name, "bool", false, false, [])
    generated[Char] = BuiltinBinding(Char.name.name, "char", false, false, [])

    # Defined as JL_DATA_TYPE in julia.h
    generated[Any] = BuiltinBinding(Any.name.name, "jlrs::value::Value", true, true, [])
    generated[Array] = BuiltinBinding(Array.body.body.name.name, "jlrs::value::array::Array", true, true, [])
    generated[Core.CodeInstance] = BuiltinBinding(Core.CodeInstance.name.name, "jlrs::value::code_instance::CodeInstance", true, false, [])
    generated[DataType] = BuiltinBinding(DataType.name.name, "jlrs::value::datatype::DataType", true, false, [])
    generated[Expr] = BuiltinBinding(Expr.name.name, "jlrs::value::expr::Expr", true, false, [])
    generated[Method] = BuiltinBinding(Method.name.name, "jlrs::value::method::Method", true, false, [])
    generated[Core.MethodInstance] = BuiltinBinding(Core.MethodInstance.name.name, "jlrs::value::method_instance::MethodInstance", true, false, [])
    generated[Core.MethodTable] = BuiltinBinding(Expr.name.name, "jlrs::value::method_table::MethodTable", true, false, [])
    generated[Module] = BuiltinBinding(Module.name.name, "jlrs::value::module::Module", true, false, [])
    generated[Core.SimpleVector] = BuiltinBinding(Core.SimpleVector.name.name, "jlrs::value::simple_vector::SimpleVector", true, false, [])
    generated[Core.SSAValue] = BuiltinBinding(Core.SSAValue.name.name, "jlrs::value::ssa_value::SSAValue", true, false, [])
    generated[Symbol] = BuiltinBinding(Symbol.name.name, "jlrs::value::symbol::Symbol", true, false, [])
    generated[Task] = BuiltinBinding(Task.name.name, "jlrs::value::task::Task", true, false, [])
    generated[Core.TypeName] = BuiltinBinding(Core.TypeName.name.name, "jlrs::value::type_name::TypeName", true, false, [])
    generated[TypeVar] = BuiltinBinding(TypeVar.name.name, "jlrs::value::type_var::TypeVar", true, false, [])
    generated[Core.TypeMapEntry] = BuiltinBinding(Core.TypeMapEntry.name.name, "jlrs::value::typemap_entry::TypeMapEntry", true, false, [])
    generated[Core.TypeMapLevel] = BuiltinBinding(Core.TypeMapLevel.name.name, "jlrs::value::typemap_level::TypeMapLevel", true, false, [])
    generated[Union] = BuiltinBinding(Union.name.name, "jlrs::value::union::Union", true, false, [])
    generated[UnionAll] = BuiltinBinding(UnionAll.name.name, "jlrs::value::union_all::UnionAll", true, false, [])

    generated
end

function generate(type::DataType, generated::Dict, rename::Dict)
    if type <: Tuple
        println("Tuple: ", type)
    elseif isabstracttype(type)
        BuiltinBinding(Any.name.name, "jlrs::value::Value", true, true, [])
    elseif length(type.parameters) > 0
        t = getproperty(type.name.module, type.name.name)
        while hasproperty(t, :body)
            t = t.body
        end
        structbinding(t, generated, rename)
    else
        structbinding(type, generated, rename)
    end
end

function generate(type::UnionAll, generated::Dict, rename::Dict)
    t = type
    while hasproperty(t, :body)
        t = t.body
    end

    structbinding(t, generated, rename)
end

function fusedeps(types::Dict{T,Set{T}})::Dict{Union{DataType,Nothing},Set{Union{DataType,Nothing}}} where T
    out = Dict()

    for (type, deps) in types
        bt = basetype(type)
        if !(bt in keys(out))
            out[bt] = Set()
        end

        for dep in deps
            push!(out[bt], basetype(dep))
        end
    end

    out
end

function bindings(types::Vector{<:Type}, rename::Dict)
    generated = generatedbindings()
    deps = getdeps(map(partialtype, types), generated)
    deps = fusedeps(deps)

    for t in toposort!(deps)
        if t in keys(generated) continue end
        generated[t] = generate(t, generated, rename)
    end

    generated
end

bindings(types::Vector{<:Type}) = bindings(types, Dict())

function printsubgeneric(field, binding, generated, fieldtype) 
    n = 0
    if hasproperty(binding, :framelifetime)
        n += binding.framelifetime
        n += binding.datalifetime
    end
    n += length(field.typeparams)
    n -= binding isa GenericBinding

    pt = partialtype(fieldtype)
    bt = basetype(fieldtype)

    if n > 0
        print("<")
        if hasproperty(binding, :framelifetime)
            if binding.framelifetime 
                print("'frame") 
                n -= 1
                if n > 0 
                    print(", ") 
                end
            end
            if binding.datalifetime 
                print("'data") 
                n -= 1
                if n > 0 
                    print(", ") 
                end
            end
        end

        m = 1
        
        while n > 0
            v = field.typeparams[m].value
            if v === nothing
                idx = findfirst(t -> t == field.typeparams[m].name, map(t-> t.name, bt.parameters))
                
                if idx !== nothing 
                    param = generated[basetype(pt.parameters[idx])]
                    print(param.rsname)
                    printsubgeneric(param, param, generated, pt.parameters[idx])  
                else
                    print(field.typeparams[m].name)
                end
            elseif v isa TypeVar
                print(v.name)
            else
                print(generated[basetype(v)].rsname)
                printsubgeneric(generated[basetype(v)], generated[basetype(v)], generated, v)
            end

            n -= 1
            if n > 0 print(", ") end
            m += 1
        end
        print(">")
    end
end

function printgeneric(field, binding, generated) 
    n = 0
    if hasproperty(binding, :framelifetime)
        n += binding.framelifetime
        n += binding.datalifetime
    end
    n += length(field.typeparams)
    n -= binding isa GenericBinding

    if n > 0
        print("<")
        if hasproperty(binding, :framelifetime)
            if binding.framelifetime 
                print("'frame") 
                n -= 1
                if n > 0 
                    print(", ") 
                end
            end
            if binding.datalifetime 
                print("'data") 
                n -= 1
                if n > 0 
                    print(", ") 
                end
            end
        end

        m = 1
        
        while n > 0
            v = field.typeparams[m].value
            if v === nothing
                print(field.typeparams[m].name)
            elseif v isa TypeVar
                print(v.name)
            else
                print(generated[basetype(v)].rsname)
                printsubgeneric(generated[basetype(v)], generated[basetype(v)], generated, v)
            end

            n -= 1
            if n > 0 print(", ") end
            m += 1
        end
        print(">")
    end
end

function printbinding(binding::BuiltinBinding, key, generated)
end

function printbinding(binding::Nothing, key, generated)
end

function printfield(field::StructField, generated)
    print("    $(field.rsname): $(field.binding.rsname)")
    printgeneric(field, field.binding, generated)
    println(",")
end

function printbinding(binding::StructBinding, key, generated)
    println(key, ":")

    println("#[repr(C)]")
    println("#[derive(Copy, Clone, JuliaStruct)]")
    println("#[jlrs(julia_type = \"$(binding.mod).$(binding.jlname)\")]")
    print("struct ", binding.rsname)
    printgeneric(binding, binding, generated)
    println(" {")
    for field in binding.fields
        printfield(field, generated)
    end
    println("}")
    println()
end

function printbindings(generated)
    for (key, binding) in generated
        printbinding(binding, key, generated)
    end
end

struct A
    f1::Int
    f2::Float64
end

struct B{T} 
    t::T
end

struct C0
    a::Int32
end

struct C
    t::B{C0}
end

struct D{U}
    t::B{U}
end

struct E{U,V}
    t::B{V}
end

struct F
    t::B
end

struct G
    t::B{Real}
end

struct H
    t::B{B{Real}}
end

struct I
    t::B{B{B{Int32}}}
end

struct J{T<:Real}
    t::T
end

struct K end

generated = bindings([A, B{Int64}, C, D{Int64}, E{Int32,2}, F, G, H, I, J, K])
printbindings(generated)

end
