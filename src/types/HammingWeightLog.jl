import Base: +

struct HammingWeightLog{T<:Integer} <: Integer
    val::T
end


for op = (:+, :<<, :>>>, :|, :&, :-, :xor)
    eval(quote
        function Base.$op(a::HammingWeightLog, b::HammingWeightLog)
            println("HH: $(a.val) $($op) $(b.val)" )
            HammingWeightLog(Base.$op(a.val, b.val))
        end
        function Base.$op(a::HammingWeightLog, b::UInt64)
            println("HI: $(a.val) $($op) $(b)" )
            HammingWeightLog(Base.$op(a.val, b))
        end
        function Base.$op(a::UInt64, b::HammingWeightLog)
            println("IH: $(a) $($op) $(b.val)" )
            HammingWeightLog(Base.$op(a, b.val))
        end
    end)
end
