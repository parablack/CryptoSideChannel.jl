import Base: +

struct HammingWeightLog{T}
    val::T
    stream::IO
end

ForgetfulHammingLog(val) = HammingWeightLog(val, Base.devnull)

extractValue(a::HammingWeightLog) = a.val
extractValue(a::Integer) = a
extractStream(a::HammingWeightLog, b) = a.stream
extractStream(a, b::HammingWeightLog) = b.stream
extractStream(a::HammingWeightLog, b::HammingWeightLog) = a.stream
logValue = Base.count_ones ∘ extractValue


for op = (:+, :*, :<<, :>>>, :|, :&, :-, :xor, :bitrotate)
    for type = ((:HammingWeightLog, :HammingWeightLog), (:HammingWeightLog, :Integer), (:Integer, :HammingWeightLog))
        eval(quote
            function Base.$op(a::$(type[1]), b::$(type[2]))
                result = HammingWeightLog(Base.$op(extractValue(a), extractValue(b)), extractStream(a,b))
                write(result.stream, "HH: $(logValue(result))\n")
                result
            end
        end)
    end
end

for type = (:AbstractArray, :Tuple)
    eval(quote
        function Base.getindex(a::$type, b::HammingWeightLog)
            HammingWeightLog(a[b.val], b.stream)
        end
    end)
 end