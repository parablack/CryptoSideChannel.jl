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
An important goal of this library is to provide new types that _behave similarly_ to integers, but include custom functionality. Those types are constructed using a [duck typing](https://en.wikipedia.org/wiki/Duck_typing) approach:
> If it walks like a duck and it quacks like a duck, then it must be a duck

Thus, our newly created types will not be a subtype of `Integer`, but instead only _behave_ like integers in certain contexts. A detailed discussion on this choice can be found in [this section](@ref int_subclass).

Technically, a definition of a very simple custom integer type could look as follows:
```julia
struct MyInt
    value::Int
end
```

Now, using Julia's powerful multiple dispatch functionality, we can start defining methods on our custom integer. For example, addition could be defined in the following way:
```julia
function Base.:(+)(a::MyInt, b::MyInt)
    # custom code (if desired) here
    MyInt(a.value + b.value)
end
```

Since we want our type to be compatible with normal integers, it is also necessary to define the following two procedures:
```julia
function Base.:(+)(a::MyInt, b::Integer)
    # custom code (if desired) here
    MyInt(a.value + b)
end
function Base.:(+)(a::Integer, b::MyInt)
    # custom code (if desired) here
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

Now, all three procedures have the exact same body. Hence, we can subsume all three procedures by using Julia's metaprogramming:
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
Here, the outer `for`-loop is evaluated at compile time. Thus, three new methods are registered by evaluating the generated function body.

Of course, we like to extend this construction to other operators. We can achieve this by metaprogramming as well. Here, we iterate over all (binary) operators that we want to define in another `for`-loop:
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

Similarly, we can implement all essential integer functionality described in [the Julia documentation](https://docs.julialang.org/en/v1/manual/mathematical-operations/). In our case, this includes the methods relevant to cryptographic operations, including
* Arithmetic
* Bitwise Operators
* Comparison
* Array accesses
* Randomness

Note that with the approach outlined above, other methods can be extended even by third-party modules. See the sections on [Extending the `GenericLog` type](@ref extending_log_funs) and [Extending the `Masked` type](@ref extending_masking_funs) for more details.

## [Subclass of `Integer`](@id int_subclass)
A canonical question to ask is whether the new `MyInt` type should be a subtype of `Integer`. At first glance, this would seem like the right choice. However, establishing this subtype relationship poses some issues:

First, multiple dispatch only works when no ambiguities in method dispatch are present. However, if multiple arguments are passed to a function, subtyping in more than one argument may introduce ambiguities. Consider the following piece of code which runs without an error:
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

Now, consider the next block of code: The only difference to above is the declaration `MyInt <: Integer`:
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

However, this second block produces an error on execution:
```
ERROR: LoadError: MethodError: getindex(::Vector{Int64}, ::MyInt) is ambiguous. Candidates:
  getindex(v::AbstractArray, i::MyInt) in Main at [...]
  getindex(A::Array, i1::Integer, I::Integer...) in Base at abstractarray.jl:1173
  getindex(A::Array, i1::Union{Integer, CartesianIndex}, I::Union{Integer, CartesianIndex}...) in Base at multidimensional.jl:637
Possible fix, define
  getindex(::Array, ::MyInt)
```

To fix this issue, more concrete method signatures have to be defined.
In the example above, since `Array <: AbstractArray`, we must define another method `getindex(::Array, ::MyInt)`. However, it is not sufficient to define this single method, but a corresponding method must be defined for every subtype of `AbstractArray`.
However, this process cannot be completed at compile-time, since new subtypes may be added dynamically. For example,  the `StaticArrays` package provides a type `StaticArray{...} <: AbstractArray{...}`.
Hence, declaring our new type as a subtype of `Integer` requires additional method declarations that may be not even known at compile-time.

Another argument against subtyping the `Integer` is the plurality of abstract integer types: One benefit of subtyping is compatibility to code that restricts arguments to `Integer` types. In this code, type annotations do not need to be changed to work with this framework. However, many projects restrict function arguments to, for example, `Signed` or `Unsigned`. Thus, those types have to be manually exchanged again.

Following the two arguments outlined above, we will not use subtypes of `Integer` throughout this project. Instead, our type declarations will not have any specific supertype.