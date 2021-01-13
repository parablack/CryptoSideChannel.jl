
module Logging
    using StaticArrays
    using Random

    abstract type LogFunction end
    abstract type SingleFunctionLog{F} <: LogFunction end

    struct GenericLog{U,T}
        val::T
        stream::AbstractArray
    end

    GenericLog{T}(val, stream) where T = GenericLog{T,typeof(val)}(val, stream)

    HammingWeightLog(val, stream)  = GenericLog{SingleFunctionLog{Base.count_ones}}(val, stream)
    ForgetfulHammingLog(val) = HammingWeightLog(val, [])

    SingleBitLog(val, stream, bit)  = GenericLog{SingleFunctionLog{x -> (x >>> bit) & 1}}(val, stream)

    FullLog(val, stream)  = GenericLog{SingleFunctionLog{identity}}(val, stream)

    StochasticLog(val, stream, bit)  = GenericLog{SingleFunctionLog{x -> (x >>> bit) & 1}}(val, stream)

    # Logs for each result the corresponding vector in the mask. Currently only for 8-bit values (AES)
    #ByteMaskLog(val, stream, mask::SVector{256})  = GenericLog{SingleFunctionLog{x -> x}}(val, stream)
    ByteMaskLog(val, stream, mask::SVector{256})  = Logging.SingleFunctionLog(val, stream, x -> mask[x+1])
    randomMask(vector_len, mask_len) = SVector{mask_len}([Random.bitrand(vector_len) for _ in 1:mask_len])

    SingleFunctionLog(val, stream, f)  = GenericLog{SingleFunctionLog{f}}(val, stream)



    logValue(a::GenericLog{SingleFunctionLog{F}}) where F = F((extractValue)(a))

    extractValue(a::GenericLog) = a.val
    extractValue(a::Integer) = a

    for op = (:+, :*, :<<, :>>>, :|, :&, :-, :xor, :bitrotate)
        for type = (:GenericLog, :Integer)
            eval(quote
                function Base.$op(a::GenericLog, b::$(type))
                    result = GenericLog{typeof(a).parameters[1]}(Base.$op(extractValue(a), extractValue(b)), a.stream)
                    push!(result.stream, logValue(result))
                    result
                end
            end)
        end

        eval(quote
            function Base.$op(a::Integer, b::GenericLog)
                result = GenericLog{typeof(b).parameters[1]}(Base.$op(extractValue(a), extractValue(b)), b.stream)
                push!(result.stream, logValue(result))
                result
            end
        end)

    end

    for type = (:AbstractArray, :Tuple)
        eval(quote
            function Base.getindex(a::$type, b::GenericLog)
                result = GenericLog{typeof(b).parameters[1]}(a[b.val], b.stream)
                push!(result.stream, logValue(result))
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