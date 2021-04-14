# Plus, minus can be directly computed on the mask

tosigned(::Type{UInt8}) = Int8
tosigned(::Type{UInt16}) = Int16
tosigned(::Type{UInt32}) = Int32
tosigned(::Type{UInt64}) = Int64
tosigned(::Type{Int8}) = Int8
tosigned(::Type{Int16}) = Int16
tosigned(::Type{Int32}) = Int32
tosigned(::Type{Int64}) = Int64

for type = ((:(Masked{Arithmetic}), :Integer), (:Integer, :(Masked{Arithmetic})), (:(Masked{Arithmetic}), :(Masked{Arithmetic})))
    eval(quote
            function Base.:(+)(a::$(type[1]), b::$(type[2]))::Masked{Arithmetic}
                val = extractValue(a) + extractValue(b)
                # mask = extractMask(a) % (tosigned(typeof(extractMask(a)))) + extractMask(b) % (tosigned(typeof(extractMask(b))))
                mask = extractMask(a) + extractMask(b)
                result = Masked{Arithmetic,typeof(val),typeof(mask)}(val, mask)
                result
            end

            function Base.:(-)(a::$(type[1]), b::$(type[2]))::Masked{Arithmetic}
                val = extractValue(a) - extractValue(b)
                mask = extractMask(a) - extractMask(b)
                result = Masked{Arithmetic,typeof(val),typeof(mask)}(val, mask)
                result
            end
        end)
end


function Base.:(==)(a::Masked{Arithmetic}, b::Masked{Arithmetic})
    # a.val + a.mask == b.val + b.mask
    # a.val - b.mask = b.val - a.mask
    a.val - b.mask == b.val - a.mask
end

function Base.:(*)(a::Masked{Arithmetic}, b::Masked{Arithmetic})::Masked{Arithmetic}
    part1 = a.val * b.val + a.val * b.mask + b.val * a.mask
    part2 = a.mask * b.mask

    Masked{Arithmetic,typeof(part1),typeof(part2)}(part1, part2)
end
function Base.:(*)(a::Masked{Arithmetic}, b::Integer)::Masked{Arithmetic}
    part1 = a.val * b
    part2 = a.mask * b
    Masked{Arithmetic,typeof(part1),typeof(part2)}(part1, part2)
end
Base.:(*)(a::Integer, b::Masked{Arithmetic})::Masked{Arithmetic} = b * a
