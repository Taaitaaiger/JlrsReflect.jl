struct BitsUInt8TupleInt32Int64
    a::UInt8
    b::Tuple{Int32, Int64}
end

struct BitsUInt8TupleInt32TupleInt16UInt16
    a::UInt8
    b::Tuple{Int32, Tuple{Int16, UInt16}}
end

@testset "Bits types with tuple fields" begin
    @test begin
        b = JlrsReflect.reflect([BitsUInt8TupleInt32Int64])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsUInt8TupleInt32Int64] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsUInt8TupleInt32Int64")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsUInt8TupleInt32Int64 {
            a: u8,
            b: ::jlrs::value::tuple::Tuple2<i32, i64>,
        }"""
    end

    @test begin
        b = JlrsReflect.reflect([BitsUInt8TupleInt32TupleInt16UInt16])
        sb = JlrsReflect.StringBindings(b)
    
        sb[BitsUInt8TupleInt32TupleInt16UInt16] === """#[repr(C)]
        #[jlrs(julia_type = "Main.BitsUInt8TupleInt32TupleInt16UInt16")]
        #[derive(Copy, Clone, JuliaStruct, IntoJulia)]
        struct BitsUInt8TupleInt32TupleInt16UInt16 {
            a: u8,
            b: ::jlrs::value::tuple::Tuple2<i32, ::jlrs::value::tuple::Tuple2<i16, u16>>,
        }"""
    end
end
