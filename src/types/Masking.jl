"""
The Masking module provides integer types that mask values. Hence, those values do never occur in memory while operations on it are performed. This makes side-channel attacks more difficult.

Further documentation is available at [Masking](@ref).
"""
module Masking

using Random
using CryptoSideChannel.Logging
import Base.convert

# Boolean masking over (Z/2Z)^k, Arithmetic masking over Z/(2^kZ)
@enum MaskType Boolean=1 Arithmetic=2

"""
    struct Masked{M, T1, T2}
        val::T1
        mask::T2
    end

The `Masked` datatype behaves like an integer, but splits its internal value into two shares. Hence, the plain value held by a `Masked` type should not be observable in memory
!!! warning
    The above statement holds **only in theory**. See the article on [problems with high-level software masking](@ref masking_problems) for details on this problem.

## Type Arguments
- `M` is the way in which the underlying value is masked. `M` can be either `Boolean` or `Arithmetic`, representing [boolean masking](@ref boolean_masking) or [arithmetic masking](@ref arithmetic_masking), respectively.
- `T1` is the type of the first share. This can be any integer-like type: A primitive integer, a `GenericLog` type, or another `Masked` type for higher-order masking.
- `T2` is the type of the second share. This should **always** be either a primitive integer type, or a `GenericLog` type.
"""
struct Masked{M, T1, T2} # T2<:Integer would be nice! But this does not work with logging.
    val::T1
    mask::T2
end

__underlyingType(::Masked{U, T, V}) where {U, T<:Integer, V} = T
__underlyingType(::Masked{U, T, V}) where {U, T, V} = __underlyingType(T)
__underlyingType(::T) where T = T

"""
    BooleanMask(v)

Create a masked integer holding value `v`. Internally, `v` will be stored in two shares, `val` and `mask`, such that `v` = `val ⊻ mask`. The latter condition is an invariant of this datatype.

It should always be the case that `mask` is a primitive type, i.e. of the type `Integer` or `GenericLog`. If higher-order masking is desired, `val` can be of the type `Masked`.
"""
function BooleanMask(val)
    mask = rand(__underlyingType(val))
    Masked{Boolean, typeof(val), typeof(mask)}(val ⊻ mask, mask)
end

"""
    ArithmeticMask(v)

Create a masked integer holding value `v`. Internally, `v` will be stored in two shares, `val` and `mask`, such that `v` = `val - mask`. The latter condition is an invariant of this datatype.

It should always be the case that `mask` is a primitive type, i.e. of the type `Integer` or `GenericLog`. If higher-order masking is desired, `val` can be of the type `Masked`.
"""
function ArithmeticMask(val)
    mask = rand(__underlyingType(val))
    Masked{Arithmetic, typeof(val), typeof(mask)}(val - mask, mask)
end

extractValue(a::Masked) = a.val
extractValue(a::Integer) = a
extractMask(a::Masked) = a.mask
extractMask(a::Integer) = convert(typeof(a), 0)

"""
    unmask(a::Masked)

Unmask the contained integer by calculating `val ⊻ mask`, or `val + mask` respectively.

Note that this function is *unsafe* with respect to side-channels. After calling this function, the data will no longer be split into two shares. Thus, this method should only be called at the end of a cryptographic algorithm to extract the final result.
"""
unmask(a::Masked{Boolean}) = a.val ⊻ a.mask
unmask(a::Masked{Arithmetic}) = a.val + a.mask
unmask(a::Integer) = a

"""
    booleanToArithmetic(a::Masked{Boolean})::Masked{Arithmetic}

Execute the algorithm outlined in [Goubin's paper](http://www.goubin.fr/papers/arith-final.pdf) to convert from boolean shares to algebraic shares.

See also: [`arithmeticToBoolean`](@ref)
"""
function booleanToArithmetic(a::Masked{Boolean})::Masked{Arithmetic}
    tau  = rand(typeof(a.mask))
    T    = ((a.val ⊻ tau) - tau) ⊻ a.val
    tau ⊻= a.mask
    A    = ((a.val ⊻ tau) - tau) ⊻ T
    return Masked{Arithmetic, typeof(A), typeof(a.mask)}(A, a.mask)
end

"""
    arithmeticToBoolean(a::Masked{Arithmetic})::Masked{Boolean}

Execute the algorithm outlined in [Goubin's paper](http://www.goubin.fr/papers/arith-final.pdf) to convert from algebraic shares to boolean shares.

See also: [`arithmeticToBoolean`](@ref)
"""
function arithmeticToBoolean(a::Masked{Arithmetic, U})::Masked{Boolean} where U
    mask  = a.mask
    rnd   = rand(U)
    T     = rnd<<1
    omega = rnd & (rnd ⊻ mask)
    x     = T ⊻ a.val
    tau   = (rnd ⊻ x) & mask
    ome2  = tau ⊻ (rnd & (rnd ⊻ mask)) ⊻ T & a.val
    for k = (1:(typeof(mask).size * 8)-1)
        tau2 = (T & mask) ⊻ ome2
        T    &= a.val
        tau2 ⊻= T
        T    = tau2 << 1
    end
    x ⊻= T
    return Masked{Boolean, typeof(x), typeof(mask)}(x, mask)
end

convert(::Type{Masked{Boolean, T1, T2}}, a::Masked{Arithmetic}) where {T1, T2} = arithmeticToBoolean(a)
convert(::Type{Masked{Arithmetic, T1, T2}}, a::Masked{Boolean}) where {T1, T2} = booleanToArithmetic(a)

# Booleans can be casted quite easily. However, randomness may be lost.
function convert(::Type{Masked{Boolean, T1, T2}}, a::Masked{Boolean, T1old, T2old}) where {T1, T2, T1old, T2old}
    t1new = convert(T1, a.val)
    t2new = convert(T2, a.mask)
    addmask = rand(typeof(a.mask))
    Masked{Boolean, T1, T2}(t1new ⊻ addmask, t2new ⊻ addmask)
end
# Performance is bad, but it is at least correct.
function convert(::Type{Masked{Arithmetic, T1, T2}}, a::Masked{Arithmetic, T1old, T2old}) where {T1, T2, T1old, T2old}
    if T1 == T1old && T2 == T2old
        return a
    end
    bool = arithmeticToBoolean(a)
    res = convert(Masked{Boolean, T1, T2}, bool)
    return booleanToArithmetic(res)
end


include("masking/BooleanMasking.jl")
include("masking/ArithmeticMasking.jl")

Base.:(~)(a::Masked{Arithmetic}) = ~arithmeticToBoolean(a)

for op = (:<<, :>>>, :bitrotate, :|, :&, :xor)
    eval(quote
    Base.$op(a::Masked{Arithmetic}, b) = Base.$op(arithmeticToBoolean(a), b)
    Base.$op(a, b::Masked{Arithmetic}) = Base.$op(a, arithmeticToBoolean(b))
    Base.$op(a::Masked{Arithmetic}, b::Masked{Arithmetic}) = Base.$op(arithmeticToBoolean(a), arithmeticToBoolean(b))
    end)
end

for op = (:+, :-, :*)
    eval(quote
    Base.$op(a::Masked{Boolean}, b) = Base.$op(booleanToArithmetic(a), b)
    Base.$op(a, b::Masked{Boolean}) = Base.$op(a, booleanToArithmetic(b))
    Base.$op(a::Masked{Boolean}, b::Masked{Boolean}) = Base.$op(booleanToArithmetic(a), booleanToArithmetic(b))
    end)
end
Base.mod(a::Masked{Arithmetic}, b) = Base.mod(arithmeticToBoolean(a), b)


plainValue(T, x::Logging.GenericLog) = plainValue(T, Logging.extractValue(x))
plainValue(T, x::Integer) = convert(T, x)

castInteger(T, x::Logging.GenericLog{U, S, Told}) where{U, S, Told} = Logging.GenericLog{U, S, T}(castInteger(T, Logging.extractValue(x)))
castInteger(T, x::Integer) = convert(T, x)

for type = (:(AbstractArray{T}), :(Tuple{Vararg{T}}))
    eval(quote
        function Base.getindex(a::$type, b::Masked{Arithmetic}) where T
            len = nextpow(2, length(a))
            masked_array = Vector{Union{T, Missing}}(missing, len)
            for i = 1:length(a)
                masked_array[mod((i - b.mask), len)+1] = a[i] - plainValue(T, mod(b.mask, len))
            end
            result = masked_array[mod(b.val, len)+1]
            if result === missing
                throw(BoundsError(a, unmask(b)))
            end
            newmask = castInteger(T, mod(b.mask, len))
            return Masked{Arithmetic, typeof(result), typeof(newmask)}(result, convert(typeof(b.mask), newmask))
        end

        Base.getindex(a::$type, b::Masked{Boolean}) where T = Base.getindex(a, booleanToArithmetic(b))
    end)
end

# Can this be done any better?
Base.hash(a::Masked) = 0


Base.:(==)(a::Masked{Arithmetic}, b::Masked{Boolean}) = arithmeticToBoolean(a) == b
Base.:(==)(a::Masked{Boolean}, b::Masked{Arithmetic}) = a == arithmeticToBoolean(b)

Base.length(::Masked) = 1

Base.rand(::MersenneTwister, ::Type{Masked{Arithmetic,T,U}}) where {T,U} = ArithmeticMask(rand(T))
Base.rand(::MersenneTwister, ::Type{Masked{Boolean,T,U}}) where {T,U} = BooleanMask(rand(T))

Base.convert(::Type{Masked{Arithmetic,T,U}}, x::T) where {U,T} = ArithmeticMask(x)
Base.convert(::Type{Masked{Boolean,T,U}}, x::T) where {U,T} = BooleanMask(x)
Base.zero(::Masked{M,T,U}) where {M,T,U} = BooleanMask(0)
Base.one(::Masked{M,T,U}) where {M,T,U} = BooleanMask(1)

function Base.show(io::IO, a::Masked{U, T1, T2}) where {U, T1, T2}
    op = U == Boolean ? "⊻" : "+"
    print(io, "Masked{$U}($(unmask(a)) = $(a.val) $(op) $(a.mask))")
end

export ArithmeticMask, BooleanMask

end