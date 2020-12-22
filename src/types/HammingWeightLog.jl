import Base: +

struct HammingWeightLog{T}
    val::T
end


for op = (:+, :*, :<<, :>>>, :|, :&, :-, :xor, :bitrotate)
    eval(quote
        function Base.$op(a::HammingWeightLog, b::HammingWeightLog)
            println("HH: $(a.val) $($op) $(b.val)" )
            HammingWeightLog(Base.$op(a.val, b.val))
        end
        function Base.$op(a::HammingWeightLog, b::Integer)
            println("HI: $(a.val) $($op) $(b)" )
            HammingWeightLog(Base.$op(a.val, b))
        end
        function Base.$op(a::Integer, b::HammingWeightLog)
            println("IH: $(a) $($op) $(b.val)" )
            HammingWeightLog(Base.$op(a, b.val))
        end
    end)
end


function Base.getindex(a::AbstractArray, b::HammingWeightLog)
    println("LookupArray: $(a) at $(b.val)")
    HammingWeightLog(a[b.val])
end