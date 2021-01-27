
module SPECK
    using StaticArrays

    function R(x, y, k)
         x = Base.bitrotate(x, -8)
         x += y

         x &= typemax(UInt64)
         x ⊻= k
         x &= typemax(UInt64)
         y = Base.bitrotate(y, 3)
         y ⊻= x
         y &= typemax(UInt64)
         (x, y)
    end

    function encrypt(pt::SVector{2,T}, k::SVector{2,T}, rounds::Int)::Tuple{T,T} where T
        y::T = pt[2]
        x::T = pt[1]
        b::T = k[2]
        a::T = k[1]

        (x, y) = R(x, y, b)

        for i::UInt64 = 0:(rounds-2)
            (a,b) = R(a, b, i)
            (x,y) = R(x, y, b)
        end

        (x, y)
    end

end