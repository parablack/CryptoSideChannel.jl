module SPECK

    function ROR(x, r)
        return ((x >>> r) | (x << (64 - r))) & typemax(UInt64)
    end

    function ROL(x, r)
        return ((x << r) | (x >>> (64 - r))) & typemax(UInt64)
    end

    function R(x, y, k)
         x = ROR(x, 8)
         x += y
         x &= typemax(UInt64)
         x ⊻= k
         x &= typemax(UInt64)
         y = ROL(y, 3)
         y ⊻= x
         y &= typemax(UInt64)
         (x, y)
    end

    function encrypt(pt::Array{T} where T<:Integer, k::Array{T} where T<:Integer, rounds::Int)::Tuple{Integer,Integer}
        y = pt[1] # TODO explicit type annotation?
        x = pt[2]
        b = k[1]
        a = k[2]

        (x, y) = R(x, y, b)

        for i::UInt64 = 0:(rounds-2)
            #println(b)
            #println("y=$y x=$x")
            (a,b) = R(a, b, i)
            (x,y) = R(x, y, b)
        end

        (x, y)
    end

end