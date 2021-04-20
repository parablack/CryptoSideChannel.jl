 # [Integer Types](@id integer_types)

```@meta
CurrentModule = CryptoSideChannel.Logging
DocTestSetup = quote
    using CryptoSideChannel
end
```

By default, Julia ships with an abstract [`Integer`](https://docs.julialang.org/en/v1/base/numbers/#Core.Integer) type, which shall be the supertype for all integers.

Furthermore, Julia's base comes with [primitive Integer types](https://docs.julialang.org/en/v1/manual/types/#Primitive-Types) like `Int8`, `UInt8`, `Int64`, `UInt64`. Note that `Int == Int64` on 64-bit systems. Hence, `Int` is a primitive type as well.

Eventually, computations are executed on primitive Integer types, while methods are often dispatched on the abstract `Integer` datatype. For this to work, it is crucial that the primitive types are subtypes of the abstract `Integer` type, which can be confirmed easily:
```julia-repl
julia> UInt8 <: Integer
true
julia> Int64 <: Integer
true
```

## Custom Integer Types
A main goal of this library is to provide new types that _behave similarly_ to integers, but include custom functionality. Those types are constructed using a [duck typing](https://en.wikipedia.org/wiki/Duck_typing) approach:
> If it walks like a duck and it quacks like a duck, then it must be a duck

Thus, our newly created types will not be of type `Integer`, but instead only _behave_ like integers in certain contexts. A detailed discussion on the problems of creating new subtypes of `Integer` can be found in [this section](@ref int_subclass).

Technically, a definition of a very simple custom Integer type could look as follows:
```julia
struct MyInt <: Integer
    value::Int
end
```

Now, using Julia's powerful multiple dispatch, we can start defining methods on our custom integer. For example, addition could be defined in the following way:
```julia
function Base.:(+)(a::MyInt, b::MyInt)
    # additional code (if desired) here
    MyInt(a.value + b.value)
end
```

Since we want our type to be compatible with normal integers, it is also necessary to define the following two procedures:
```julia
function Base.:(+)(a::MyInt, b::Integer)
    # additional code
    MyInt(a.value + b)
end
function Base.:(+)(a::Integer, b::MyInt)
    # additional code
    MyInt(a + b.value)
end
```

Extending this to other operators is, of course, extremely tedious and results in large code duplicates. This can be avoided by the use of metaprogramming to generate those functions. Consider the following function definitions instead:
```julia
extractValue(a::MyInt) = a.value
extractValue(a::Integer) = a

function Base.:(+)(a::MyInt, b::MyInt)
    MyInt(extractValue(a) + extractValue(b))
end
function Base.:(+)(a::MyInt, b::Integer)
    MyInt(extractValue(a) + extractValue(b))
end
function Base.:(+)(a::Integer, b::MyInt)
    MyInt(extractValue(a) + extractValue(b))
end
```

Now, all three procedures have the exact same body. Hence, we can subsume all three procedures using a for-loop in metaprogramming:
```julia
for type = ((:MyInt, :MyInt), (:MyInt, :Integer), (:Integer, :MyInt))
    eval(quote
        function Base.:(+)(a::$(type[1]), b::$(type[2]))
            # custom code here
            MyInt(extractValue(a) + extractValue(b))
        end
    end)
end
```

Now, we want to add generic other operatoros. We can achieve this by also iterating over all (binary) operators that we want to define:
```julia
for op = (:+, :*, :-, :div, :mod)
    for type = ((:MyInt, :MyInt), (:MyInt, :Integer), (:Integer, :MyInt))
        eval(quote
            function Base.$op(a::$(type[1]), b::$(type[2]))
                MyInt(Base.$op(extractValue(a), extractValue(b)))
            end
        end)
    end
end
```

In a similar way, we can implement all essential integer functionality described in [the Julia documentation](https://docs.julialang.org/en/v1/manual/mathematical-operations/). In our case, this includes the methods relevant to cryptographic operations, including
* Arithmetic
* Bitwise Operators
* Comparison
* Array accesses
* Randomness

Note that with the approach outlined above, other methods can be extended even by third-party modules. See the sections on [Extending the `GenericLog` type](@ref extending_log_funs) and [Extending the `Masked` type](@ref extending_masking_funs) for more details.

## [Subclass of `Integer`](@id int_subclass)
TODO text Discuss why this may be a bad idea.


The following piece of code works:
```julia
struct MyInt
    value::Int
end

function Base.getindex(v::AbstractArray, i::MyInt)
    return v[i.value]
end

v = [1, 2, 3]
i = MyInt(2)

v[i]
```


The following code produces an error. The single difference to above is the declaration `MyInt <: Integer`:
```julia
struct MyInt <: Integer
    value::Int
end

function Base.getindex(v::AbstractArray, i::MyInt)
    return v[i.value]
end

v = [1, 2, 3]
i = MyInt(2)

v[i]
```

```
ERROR: LoadError: MethodError: getindex(::Vector{Int64}, ::MyInt) is ambiguous. Candidates:
  getindex(v::AbstractArray, i::MyInt) in Main at [...]
  getindex(A::Array, i1::Integer, I::Integer...) in Base at abstractarray.jl:1173
  getindex(A::Array, i1::Union{Integer, CartesianIndex}, I::Union{Integer, CartesianIndex}...) in Base at multidimensional.jl:637
Possible fix, define
  getindex(::Array, ::MyInt)
```

## Methods available for logging
Exhaustive list? TODO
```@docs
Base.abs(::GenericLog)
```