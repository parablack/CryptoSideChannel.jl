 # Boolean operator xor can be performed component-wise for each operation
    op = :xor
    for type = ((:(Masked{Boolean}), :Integer), (:Integer, :(Masked{Boolean})), (:(Masked{Boolean}), :(Masked{Boolean})))
        eval(quote
                function Base.$op(a::$(type[1]), b::$(type[2]))
                    val = Base.$op(extractValue(a), extractValue(b))
                    mask = Base.$op(extractMask(a), extractMask(b))
                    result = Masked{Boolean,typeof(val)}(val, mask)
                    result
                end
            end)
    end

    # Boolean operators: <<, >>>, bitrotate
    # those operators can be performed component-wise for each operation, if the second operator is an integer constant.
    for op = (:<<, :>>>, :bitrotate)
        eval(quote
                function Base.$op(a::Masked{Boolean}, b::Integer)
                    val = Base.$op(extractValue(a), b)
                    mask = Base.$op(extractMask(a), b)
                    addmask = rand(typeof(a.val))

                    result = Masked{Boolean,typeof(val)}(val ⊻ addmask, mask ⊻ addmask)
                    result
                end
            end)
    end

    # :& requires a mask refreshing, since randomness is lost
    op = :&
    eval(quote
            function Base.$op(a::Masked{Boolean}, b::Integer)
                val = Base.$op(extractValue(a), b)
                mask = Base.$op(extractMask(a), b)
                addmask = rand(typeof(a.val))
                result = Masked{Boolean,typeof(val)}(val ⊻ addmask, mask ⊻ addmask)
                result
            end
            Base.$op(a::Integer, b::Masked{Boolean}) = Base.$op(b, a)
        end)

    op = :|
    eval(quote
            function Base.$op(a::Masked{Boolean}, b::Integer)
                val = Base.$op(extractValue(a), b)
                mask = Base.$op(extractMask(a), b) ⊻ b
                addmask = rand(typeof(a.val))
                result = Masked{Boolean,typeof(val)}(val ⊻ addmask, mask ⊻ addmask)
                result
            end
            Base.$op(a::Integer, b::Masked{Boolean}) = Base.$op(b, a)
        end)
