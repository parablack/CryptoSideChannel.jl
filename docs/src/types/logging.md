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

It may be useful to extract the content of a `GenericLog` type, for example, at the end of a cryptographic calculation.
```@docs
Logging.extractValue
```

## Reduction functions
A **reduction function** for a `GenericLog` over base type `T` should take any value of type `T`, and produce any result that eventually is logged. Reasonable choices for reduction functions could be a model of side-channel emissions. For example, the [Hamming weight](https://iacr.org/archive/ches2004/31560016/31560016.pdf) could be a possible model which is already pre-defined. The following types with commonly used reduction functions are already pre-defined:

There are already several logging datatypes pre-defined. Creating instances of those types is as easy as specifying a closure returning the logging destination, and the underlying value.

### [Pre-defined logging types](@id predefined_types)
The following logging types are already pre-defined:

```@docs
HammingWeightLog
FullLog
SingleBitLog
StochasticLog
```

### Using custom reduction functions
Besides the pre-defined types, this framework allows free choices of reduction functions, hence providing great flexibility. To define custom reduction functions, the `SingleFunctionLog` interface should be used.
With this type, it is possible to specify a custom function that takes the intermemdiate value and output the reduced result.

```@docs
SingleFunctionLog
```

For example, it is possible to define the [`HammingWeightLog`](@ref) based on this method as follows:
```julia
HammingWeightLog(val, stream)  =
    GenericLog{SingleFunctionLog{Base.count_ones},stream,typeof(val)}(val)
```



## [Defining new methods for `GenericLog` types](@id extending_log_funs)

All basic operations provided by the Julia standard library can also be executed on `GenericLog` types. However, there may be the need for custom operations, e.g. defined by a third-party library. Implementing a new binary operation on `GenericLog` consists of defining the following three methods:

```julia
function Base.$op(a::GenericLog{U,S}, b::GenericLog) where {U,S}
    res = Base.$op(extractValue(a), extractValue(b))
    result = GenericLog{U,S,typeof(res)}(res)
    push!(typeof(b).parameters[2](), logValue(result))
    result
end

Base.$op(a::Integer, b::GenericLog{U,S}) where {U,S} = ...
Base.$op(a::GenericLog{U,S}, b::Integer) where {U,S} = ...
```
