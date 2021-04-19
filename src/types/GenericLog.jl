"""
The Logging module allows for recording traces of program executions.
This module provides the type `GenericLog`, which can be substituted for an integer.
With this type, arithmetic operations, as well as certain memory operations will be logged to a trace array.

Further documentation is available at [Logging](@ref logging).
"""
module Logging

using StaticArrays
using Random
using Base.Docs

"""
    abstract type LogFunction end

This type is used for dispatching reduction functions. All reduction functions must be subtypes of this type.
"""
abstract type LogFunction end

"""
    abstract type SingleFunctionLog{F} <: LogFunction end

A wrapper for simple reduction functions that take a single argument and output a reduced value.
"""
abstract type SingleFunctionLog{F} <: LogFunction end

# S should be a closure returning an array
"""
    struct GenericLog{U,S,T}
        val::T
    end

The `GenericLog` datatype behaves like an integer, but additionally logs a trace of all values contained. Technically, this type logs its reduced value every time a operation is performed on it.

# Type Arguments
- `T` is the underlying type that the logging should be performed upon. `T` may be a primitive integer type (like `UInt8` or `Int`), or any integer-like type (for example, another instance of `GenericLog` or a `Masked` integer).
- `U` should be a container holding a reduction function. The purpose of this reduction function is to preprocess all single values stores in this type. Most commonly, only a value derived from the intermediate values should be logged, like the Hamming weight, or the least significant bit. The reduction function should compute this value. More on this topic can be found at the chapter on [Reduction functions](@ref).
- `S` is a **closure** returning the array where values should be logged to. Note that `S` must be a [bits type](https://docs.julialang.org/en/v1/base/base/#Base.isbitstype). This can only be the case if the array returned by `S` is a global variable.
"""
struct GenericLog{U,S,T}
    val::T
end

"""
    extractValue(a::GenericLog)
    extractValue(a::Integer)

Extracts the internal value from the `GenericLog` datatype. Behaves like the identity function if an `Integer` value is passed.
"""
extractValue(a::GenericLog) = a.val
extractValue(a::Integer) = a

SingleFunctionLog(val, stream, f)  = GenericLog{SingleFunctionLog{f},stream,typeof(val)}(val)

logValue(a::GenericLog{SingleFunctionLog{F}}) where F = F((extractValue)(a))

# Pre-defined types for Logging

@doc raw"""
    HammingWeightLog(val, stream)

Creates a logging datatype that logs the [Hamming weight](https://en.wikipedia.org/wiki/Hamming_weight) of the underlying value.

## Arguments
- `val`: the value that should be wrapped around.
- `stream`: A **closure** returning the array that should be logged to. Note that `stream` must be a `bits` type.

## Example
```@meta
DocTestSetup = quote
    using CryptoSideChannel
end
```

```jldoctest
julia> trace = [];

julia> closure = () -> trace;

julia> a = Logging.HammingWeightLog(42, closure)
Log{Int64, 42}
julia> b = a + 1
Log{Int64, 43}
julia> c = a - 42
Log{Int64, 0}
julia> trace
2-element Vector{Any}:
 4
 0
```
Notice that $(43)_{10} = (101011)_2$. Hence, the Hamming weight of $43$ is $4$.
"""
HammingWeightLog(val, stream)  = GenericLog{SingleFunctionLog{Base.count_ones},stream,typeof(val)}(val)
forgetful_closure = () -> []

# Testing purposes only
ForgetfulHammingLog(val) = HammingWeightLog(val, forgetful_closure)

"""
    SingleBitLog(val, stream, bit)

Creates a logging datatype that logs the value of **a single bit** of the underlying value. The bit that is logged is selected with the `bit` argument.

## Arguments
- `val`: the value that should be wrapped around.
- `stream`: A **closure** returning the array that should be logged to. Note that `stream` must be a `bits` type.
- `bit`: The position of the bit that should be logged, where `0` is the least significant bit.
"""
SingleBitLog(val, stream, bit)  = GenericLog{SingleFunctionLog{x -> (x >>> bit) & 1},stream,typeof(val)}(val)

"""
    FullLog(val, stream)

Creates a logging datatype that logs the full underlying value.

## Arguments
- `val`: the value that should be wrapped around.
- `stream`: A **closure** returning the array that should be logged to. Note that `stream` must be a `bits` type.

## Example
```@meta
DocTestSetup = quote
    using CryptoSideChannel
end
```
```jldoctest
julia> trace = [];

julia> closure = () -> trace;

julia> a = Logging.FullLog(42, closure)
Log{Int64, 42}
julia> b = a + 1
Log{Int64, 43}
julia> c = a - 42
Log{Int64, 0}
julia> trace
2-element Vector{Any}:
 43
  0
```
"""
FullLog(val, stream)  = GenericLog{SingleFunctionLog{identity},stream,typeof(val)}(val)


function StochasticLog(val, stream, template_for_value, noise_closure)
    intermediate_function = x -> template_for_value(x) + rand(noise_closure())
    @assert (isbitstype(typeof(intermediate_function)))
    GenericLog{SingleFunctionLog{intermediate_function}, stream, typeof(val)}(val)
end


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