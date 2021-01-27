
module Masking
    using Random

    # Boolean masking over (Z/2Z)^k, Arithmetic masking over Z/(2^kZ)
    @enum MaskType Boolean=1 Arithmetic=2

    struct Masked{M, T}
        val::T
        mask::T
    end

    function BooleanMask(val)
        mask = rand(typeof(val))
        Masked{Boolean, typeof(val)}(val ⊻ mask, mask)
    end
    function ArithmeticMask(val)
        mask = rand(typeof(val))
        Masked{Arithmetic, typeof(val)}(val - mask, mask)
    end

    extractValue(a::Masked) = a.val
    extractValue(a::Integer) = a
    extractMask(a::Masked) = a.mask
    extractMask(a::Integer) = convert(typeof(a), 0)

    unmask(a::Masked{Boolean}) = a.val ⊻ a.mask
    unmask(a::Masked{Arithmetic}) = a.val + a.mask
    unmask(a::Integer) = a


    function booleanToArithmetic(a::Masked{Boolean})::Masked{Arithmetic}
        tau  = rand(typeof(a.val))
        T    = (a.val ⊻ tau) - tau
        T   ⊻= a.val
        tau ⊻= a.mask
        A    = (a.val ⊻ tau) - tau
        A   ⊻= T
        return Masked{Arithmetic, typeof(A)}(A, a.mask)
    end
    function arithmeticToBoolean(a::Masked{Arithmetic})::Masked{Boolean}
        tau   = rand(typeof(a.val))
        T     = tau<<1
        omega = tau & (tau ⊻ a.mask)
        x     = T ⊻ a.val
        tau  ⊻= x
        tau  &= a.mask
        omega⊻= tau
        tau   = T & a.val
        omega⊻= tau
        for k = (1:(typeof(a.val).size * 8)-1)
            tau = T & a.mask
            tau ⊻= omega
            T   &= a.val
            tau ⊻= T
            T   = tau << 1
        end
        x ⊻= T
        return Masked{Boolean, typeof(x)}(x, a.mask)
    end

    include("masking/BooleanMasking.jl")
    include("masking/ArithmeticMasking.jl")

    for op = (:<<, :>>>, :bitrotate, :|, :&, :xor)
        eval(quote
        Base.$op(a::Masked{Arithmetic}, b) = Base.$op(arithmeticToBoolean(a), b)
        Base.$op(a, b::Masked{Arithmetic}) = Base.$op(a, arithmeticToBoolean(b))
        Base.$op(a::Masked{Arithmetic}, b::Masked{Arithmetic}) = Base.$op(arithmeticToBoolean(a), arithmeticToBoolean(b))
        end)
    end

    for op = (:+, :-)
        eval(quote
        Base.$op(a::Masked{Boolean}, b) = Base.$op(booleanToArithmetic(a), b)
        Base.$op(a, b::Masked{Boolean}) = Base.$op(a, booleanToArithmetic(b))
        Base.$op(a::Masked{Boolean}, b::Masked{Boolean}) = Base.$op(booleanToArithmetic(a), booleanToArithmetic(b))
        end)
    end


    #for type = (:AbstractArray, :Tuple)
    #    eval(quote
    #        function Base.getindex(a::$type, b::GenericLog{U,S}) where {U,S}
    #            result = GenericLog{U,S,typeof(a[b.val])}(a[b.val])
    #            push!(typeof(b).parameters[2](), logValue(result))
    #            result
    #        end
    #    end)
    #end
    #
    #function Base.:(==)(a::GenericLog, b::GenericLog)
    #    extractValue(a) == extractValue(b)
    #end
    #function Base.hash(a::GenericLog)
    #    hash(extractValue(a))
    #end
    function Base.show(io::IO, a::Masked{U}) where U
        op = U == Boolean ? "⊻" : "+"
        print(io, "Masked{$U}($(unmask(a)) = $(a.val) $(op) $(a.mask))")
    end

    val1 = BooleanMask(0x42)

end