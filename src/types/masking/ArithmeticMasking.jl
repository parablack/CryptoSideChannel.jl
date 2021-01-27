# Plus, minus can be directly computed on the mask

for op = (:+, :-)
    for type = ((:(Masked{Arithmetic}), :Integer), (:Integer, :(Masked{Arithmetic})), (:(Masked{Arithmetic}), :(Masked{Arithmetic})))
        eval(quote
                function Base.$op(a::$(type[1]), b::$(type[2]))
                    val = Base.$op(extractValue(a), extractValue(b))
                    mask = Base.$op(extractMask(a), extractMask(b))
                    result = Masked{Arithmetic,typeof(val)}(val, mask)
                    result
                end
            end)
    end
end

# TODO multiplication?