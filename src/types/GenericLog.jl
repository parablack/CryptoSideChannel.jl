
module Logging
    using StaticArrays
    using Random

    abstract type LogFunction end
    abstract type SingleFunctionLog{F} <: LogFunction end

    # S should be a closure returning an array
    struct GenericLog{U,S,T}
        val::T
    end

   # GenericLog{T}(val) where T = GenericLog{T,typeof(val)}(val)
   # GenericLog{U,S}(val) where {U,S} = GenericLog{U,S,typeof(val)}(val)

    HammingWeightLog(val, stream)  = GenericLog{SingleFunctionLog{Base.count_ones},stream,typeof(val)}(val)
    forgetful_closure = () -> []
    ForgetfulHammingLog(val) = HammingWeightLog(val, forgetful_closure)

    SingleBitLog(val, stream, bit)  = GenericLog{SingleFunctionLog{x -> (x >>> bit) & 1},stream,typeof(val)}(val)

    FullLog(val, stream)  = GenericLog{SingleFunctionLog{identity},stream,typeof(val)}(val)

   # StochasticLog(val, stream, bit)  = GenericLog{SingleFunctionLog{x -> (x >>> bit) & 1}}(val, stream)

    # Logs for each result the corresponding vector in the mask. Currently only for 8-bit values (AES)
    #ByteMaskLog(val, stream, mask::SVector{256})  = GenericLog{SingleFunctionLog{x -> x}}(val, stream)
   # ByteMaskLog(val, stream, mask::SVector{256})  = Logging.SingleFunctionLog(val, stream, x -> mask[x+1])
    randomMask(vector_len, mask_len) = SVector{mask_len}([Random.bitrand(vector_len) for _ in 1:mask_len])

    SingleFunctionLog(val, stream, f)  = GenericLog{SingleFunctionLog{f},stream,typeof(val)}(val)



    logValue(a::GenericLog{SingleFunctionLog{F}}) where F = F((extractValue)(a))

    extractValue(a::GenericLog) = a.val
    extractValue(a::Integer) = a

    for op = (:+, :*, :<<, :>>>, :|, :&, :-, :xor, :bitrotate)
        for type = (:GenericLog, :Integer)
            eval(quote
                function Base.$op(a::GenericLog{U,S}, b::$(type)) where {U,S}
                    res = Base.$op(extractValue(a), extractValue(b))
                    result = GenericLog{U,S,typeof(res)}(res)
                    push!(S(), logValue(result))
                    result
                end
            end)
        end

        eval(quote
            function Base.$op(a::Integer, b::GenericLog{U,S}) where {U,S}
                res = Base.$op(extractValue(a), extractValue(b))
                result = GenericLog{U,S,typeof(res)}(res)
                push!(typeof(b).parameters[2](), logValue(result))
                result
            end
        end)

    end

    for type = (:AbstractArray, :Tuple)
        eval(quote
            function Base.getindex(a::$type, b::GenericLog{U,S}) where {U,S}
                result = GenericLog{U,S,typeof(a[b.val])}(a[b.val])
                push!(typeof(b).parameters[2](), logValue(result))
                result
            end
        end)
    end

    function Base.:(==)(a::GenericLog, b::GenericLog)
        extractValue(a) == extractValue(b)
    end
    function Base.hash(a::GenericLog)
        hash(extractValue(a))
    end
    function Base.show(io::IO, a::GenericLog)
        print(io, "Log{$(extractValue(a))}")
    end
end