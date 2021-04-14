"""
The Logging module allows for recording traces of program executions.
This module provides the type `GenericLog`, which can be substituted for an integer.
With this type, arithmetic operations, as well as certain memory operations will be logged to a trace array.

Further documentation is available at [Logging](@ref).
"""
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


# Logs for each result the corresponding vector in the mask. Currently only for 8-bit values (AES)
#ByteMaskLog(val, stream, mask::SVector{256})  = GenericLog{SingleFunctionLog{x -> x}}(val, stream)
# ByteMaskLog(val, stream, mask::SVector{256})  = Logging.SingleFunctionLog(val, stream, x -> mask[x+1])
randomBitMask(vector_len, mask_len) = SVector{mask_len}([Random.bitrand(vector_len) for _ in 1:mask_len])


SingleFunctionLog(val, stream, f)  = GenericLog{SingleFunctionLog{f},stream,typeof(val)}(val)


function StochasticLog(val, stream, template_for_value, noise_closure)
    intermediate_function = x -> template_for_value(x) + rand(noise_closure())
    @assert (isbitstype(typeof(intermediate_function)))
    GenericLog{SingleFunctionLog{intermediate_function}, stream, typeof(val)}(val)
end

logValue(a::GenericLog{SingleFunctionLog{F}}) where F = F((extractValue)(a))

extractValue(a::GenericLog) = a.val
extractValue(a::Integer) = a

function Base.:(-)(a::GenericLog{U,S}) where {U,S}
    res = -extractValue(a)
    result = GenericLog{U,S,typeof(res)}(res)
    push!(S(), logValue(result))
    result
end

for op = (:+, :*, :<<, :>>>, :|, :&, :-, :xor, :bitrotate, :mod)
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
        function Base.setindex!(A::$type, X, inds::GenericLog{U,S}...) where {U,S}
            Base.setindex!(A, X, map(extractValue, inds)...)
        end
    end)
end

function Base.:(==)(a::GenericLog, b::GenericLog)
    extractValue(a) == extractValue(b)
end
function Base.hash(a::GenericLog)
    hash(extractValue(a))
end
function Base.show(io::IO, a::GenericLog{A, B, T}) where {A, B, T}
    print(io, "Log{$(T), $(extractValue(a))}")
end

Base.rand(::MersenneTwister, ::Type{GenericLog{U,S,T}}) where {U,S,T} = GenericLog{U,S,T}(rand(T))

Base.convert(::Type{GenericLog{U, S, Tnew}}, x::GenericLog{U, S, Told}) where {U, S, Tnew, Told} = GenericLog{U, S, Tnew}(convert(Tnew, extractValue(x)))

end