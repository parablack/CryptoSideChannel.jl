import Base: +

@enum LogType HammingWeight=1 LSB=2

struct GenericLog{U,T}
    val::T
    stream::AbstractArray
end

GenericLog{T}(val, stream) where T = GenericLog{T,typeof(val)}(val, stream)

HammingWeightLog(val, stream)  = GenericLog{HammingWeight}(val, stream)
logValue(a::GenericLog{HammingWeight}) = (Base.count_ones ∘ extractValue)(a)
ForgetfulHammingLog(val) = HammingWeightLog(val, [])
extractValue(a::GenericLog) = a.val
extractValue(a::Integer) = a

for op = (:+, :*, :<<, :>>>, :|, :&, :-, :xor, :bitrotate)
    for type = (:GenericLog, :Integer)
        eval(quote
            function Base.$op(a::GenericLog, b::$(type))
                result = GenericLog{typeof(a).parameters[1]}(Base.$op(extractValue(a), extractValue(b)), a.stream)
                append!(result.stream, logValue(result))
                result
            end
        end)
    end

    eval(quote
        function Base.$op(a::Integer, b::GenericLog)
            result = GenericLog{typeof(b).parameters[1]}(Base.$op(extractValue(a), extractValue(b)), b.stream)
            append!(result.stream, logValue(result))
            result
        end
    end)

end

for type = (:AbstractArray, :Tuple)
    eval(quote
        function Base.getindex(a::$type, b::GenericLog)
            result = GenericLog{typeof(b).parameters[1]}(a[b.val], b.stream)
            append!(result.stream, logValue(result))
            result
        end
    end)
 end

function Base.:(==)(a::GenericLog, b::GenericLog)
    extractValue(a) == extractValue(b)
end
function Base.hash(a::GenericLog)
    hash(extractValue(a))
end
function Base.show(io::IO, a::GenericLog)
    print(io, "Log{$(extractValue(a))}")
end
