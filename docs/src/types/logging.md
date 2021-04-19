# [Logging: The `GenericLog` Datatype](@id logging)

```@meta
CurrentModule = CryptoSideChannel.Logging
DocTestSetup = quote
    using CryptoSideChannel
end
```

```@docs
Logging.GenericLog
```

Most operations on integers can also be performed on instances of `GenericLog`. By default, this includes the most common operations like calculations, array accesses, and more.
However, it is easy to extend this functionality to other methods if desired. See the chapter on [Defining new methods for `GenericLog` types](@ref extending_log_funs) for more details.

It may be useful to extract the content of a `GenericLog` type, for example at the end of a cryptographic calculation.
```@docs
Logging.extractValue
```

## Pre-defined logging types

There are already several logging datatypes pre-defined. Creating instances of those types is as easy as specifying a closure returning the logging destination, and the underlying value.

The following logging types are already pre-defined:

```@docs
HammingWeightLog
FullLog
SingleBitLog
StochasticLog
```

## Reduction functions
A **reduction function** for a `GenericLog` over base type `T` should take any value of type `T`, and produce any result that eventually is logged. Reasonable choices for reduction functions could be a model of side-channel emissions. For example, the [Hamming weight](https://iacr.org/archive/ches2004/31560016/31560016.pdf) could be a reasonable model which is already pre-defined.
However, this framework allows free choices of reduction functions, hence providing great flexibility.

### Single Function Log
Most reduction functions simply take the intermemdiate value and output the reduced result. The type `SingleFunctionLog` captures this pattern.

```@docs
SingleFunctionLog
```

For example, it is possible to define the [`HammingWeightLog`](@ref) based on this method as follows:
```julia
HammingWeightLog(val, stream)  =
    GenericLog{SingleFunctionLog{Base.count_ones},stream,typeof(val)}(val)
```

### Creating your own reduction function

TODO hamming distance, explain custom `logValue`



## [Defining new methods for `GenericLog` types](@id extending_log_funs)
TODO: Either explain
```julia
function Base.$op(a::Integer, b::GenericLog{U,S}) where {U,S}
    res = Base.$op(extractValue(a), extractValue(b))
    result = GenericLog{U,S,typeof(res)}(res)
    push!(typeof(b).parameters[2](), logValue(result))
    result
end
```
pattern or include generic code like
```julia
registerFunction(Base.:(+))
```