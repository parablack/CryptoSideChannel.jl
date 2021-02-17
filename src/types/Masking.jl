"""
The Masking module provides integer types that mask values. Hence, those values do never occur in memory while operations on it are performed. This makes side-channel attacks more difficult.

Further documentation is available at [Masking](@ref).
"""
module Masking
    using Random
    import Base.convert

    # Boolean masking over (Z/2Z)^k, Arithmetic masking over Z/(2^kZ)
    @enum MaskType Boolean=1 Arithmetic=2

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

It should always be the case that `mask` is a primitive type, i.e. of the shape `Integer` or `GenericLog`. If higher-order masking is desired, `val` can be of the shape `Masked`.
"""
    function BooleanMask(val)
        mask = rand(__underlyingType(val))
        Masked{Boolean, typeof(val), typeof(mask)}(val ⊻ mask, mask)
    end
"""
    ArithmeticMask(v)

Create a masked integer holding value `v`. Internally, `v` will be stored in two shares, `val` and `mask`, such that `v` = `val + mask`. The latter condition is an invariant of this datatype.

It should always be the case that `mask` is a primitive type, i.e. of the shape `Integer` or `GenericLog`. If higher-order masking is desired, `val` can be of the shape `Masked`.
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

Note that this function is *unsafe*. After calling this function, the data will no longer be split into two shares. Thus, this method is for testing only.
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
        rnd   = rand(U)
        T     = rnd<<1
        omega = rnd & (rnd ⊻ a.mask)
        x     = T ⊻ a.val
        tau   = (rnd ⊻ x) & a.mask
        ome2  = tau ⊻ (rnd & (rnd ⊻ a.mask)) ⊻ T & a.val
        for k = (1:(typeof(a.mask).size * 8)-1)
            tau2 = (T & a.mask) ⊻ ome2
            T    &= a.val
            tau2 ⊻= T
            T    = tau2 << 1
        end
        x ⊻= T
        return Masked{Boolean, typeof(x), typeof(a.mask)}(x, a.mask)
    end

    convert(::Type{Masked{Boolean, T1, T2}}, a::Masked{Arithmetic}) where {T1, T2} = arithmeticToBoolean(a)
    convert(::Type{Masked{Arithmetic, T1, T2}}, a::Masked{Boolean}) where {T1, T2} = booleanToArithmetic(a)

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


    for type = (:(AbstractArray{T}), :(Tuple{Vararg{T}}))
        eval(quote
            function Base.getindex(a::$type, b::Masked{Arithmetic}) where T
                len = nextpow(2, length(a))
                masked_array = Vector{Union{T, Missing}}(missing, len)
                for i = 1:length(a)
                    masked_array[mod((i - b.mask), len)+1] = a[i] - convert(T, mod(b.mask, len))
                end

                result = masked_array[mod(b.val, len)+1]
                if result === missing
                    throw(BoundsError(a, unmask(b)))
                end
                return Masked{Arithmetic, typeof(result), Base.nonmissingtype(T)}(result, mod(b.mask, len))
            end
            Base.getindex(a::$type, b::Masked{Boolean}) where T = Base.getindex(a, booleanToArithmetic(b))
        end)
end

    # Can this be done any better?
    Base.hash(a::Masked) = 0


    Base.:(==)(a::Masked{Arithmetic}, b::Masked{Boolean}) = arithmeticToBoolean(a) == b
    Base.:(==)(a::Masked{Boolean}, b::Masked{Arithmetic}) = a == arithmeticToBoolean(b)


    Base.rand(::MersenneTwister, ::Type{Masked{Arithmetic,T,U}}) where {T,U} = ArithmeticMask(rand(T))
    Base.rand(::MersenneTwister, ::Type{Masked{Boolean,T,U}}) where {T,U} = BooleanMask(rand(T))


    function Base.show(io::IO, a::Masked{U, T1, T2}) where {U, T1, T2}
        op = U == Boolean ? "⊻" : "+"
        print(io, "Masked{$U}($(unmask(a)) = $(a.val) $(op) $(a.mask))")
    end

end