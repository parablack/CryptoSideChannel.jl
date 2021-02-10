    # Bitwise inversion is easy, as we only have to invert the mask
    function Base.:(~)(a::Masked{Boolean})::Masked{Boolean}
        Masked{Boolean,typeof(a.val),typeof(a.mask)}(a.val, ~a.mask)
    end

    # Boolean operator xor can be performed component-wise for each operation
    op = :xor
    for type = ((:(Masked{Boolean}), :Integer), (:Integer, :(Masked{Boolean})), (:(Masked{Boolean}), :(Masked{Boolean})))
        eval(quote
"""
    Base.$($op)(a::$($(type[1])), b::$($(type[2])))

MetaTest.
"""
                function Base.$op(a::$(type[1]), b::$(type[2]))::Masked{Boolean}
                    val = Base.$op(extractValue(a), extractValue(b))
                    mask = Base.$op(extractMask(a), extractMask(b))
                    result = Masked{Boolean,typeof(val),typeof(mask)}(val, mask)
                    result
                end
            end)
    end

    # Boolean operators: <<, >>>, bitrotate
    # those operators can be performed component-wise for each operation, if the second operator is an integer constant.
    for op = (:<<, :>>>, :bitrotate)
        eval(quote
                function Base.$op(a::Masked{Boolean}, b::Integer)::Masked{Boolean}
                    val = Base.$op(extractValue(a), b)
                    mask = Base.$op(extractMask(a), b)
                    addmask = rand(typeof(a.mask))

                    result = Masked{Boolean,typeof(val),typeof(mask ⊻ addmask)}(val ⊻ addmask, mask ⊻ addmask)
                    result
                end
            end)
    end

    # & requires a mask refreshing, since randomness is lost
"""
    Base.:(&)(a::Masked, b::Integer)
    Base.:(&)(b::Integer, a::Masked)
    a & b

Calculate the bitwise and of the masked value and an integer.

Internally, this function operates on a boolean representation. Bitwise and is performed on both shares separately. Since afterwards neither of the shares is still uniformly random (except if there was no 0-bit in `b`), the mask of the result is re-randomized.
"""
    function Base.:(&)(a::Masked{Boolean}, b::Integer)::Masked{Boolean}
        val = extractValue(a) & b
        mask = extractMask(a) & b
        addmask = rand(typeof(a.mask))
        result = Masked{Boolean,typeof(val),typeof(mask ⊻ addmask)}(val ⊻ addmask, mask ⊻ addmask)
        result
    end
    Base.:(&)(a::Integer, b::Masked{Boolean}) = b & a

"""
    Base.:(&)(a::Masked, b::Masked)
    a & b

Calculate the bitwise and of two masked values.

Internally, this function operates on a boolean representation. This function uses the fact that bitwise and distributes over bitwise xor. (Since and is multiplication, xor is addition in ``\\mathbb{F}_{2^n}``)
"""
    function Base.:(&)(a::Masked{Boolean}, b::Masked{Boolean})
        # (a.val ⊻ a.mask)   &   (b.val ⊻ b.mask)
        # Equals, by distributivity, to
        # (a.val & b.val) ⊻ (a.val & b.mask) ⊻ (a.mask & b.val) ⊻ (a.mask & b.mask)
        # We can split this to
        # ((a.val & b.val) ⊻ (a.val & b.mask) ⊻ (a.mask & b.val)) ⊻ (a.mask & b.mask)
        # res.val  = (a.val & b.val) ⊻ (a.val & b.mask) ⊻ (a.mask & b.val)
        # res.mask = (a.mask & b.mask)
        # Note that this preserves the invariant of typeof(res.mask) <: Integer

        # However, randomness is lost when only considering (a.mask & b.mask). Thus, randomness must be refreshed in this step
        addmask = rand(typeof(a.mask))
        part1  = (a.val & b.val)  ⊻ addmask
        part1 ⊻= (a.val & b.mask) ⊻ (a.mask & b.val)
        part2  = (a.mask & b.mask) ⊻ addmask
        Masked{Boolean,typeof(part1),typeof(part2)}(part1, part2)
    end

    function Base.:(|)(a::Masked{Boolean}, b::Integer)
        val = extractValue(a) | b
        mask = (extractMask(a) | b) ⊻ b
        addmask = rand(typeof(a.mask))
        result = Masked{Boolean,typeof(val),typeof(mask)}(val ⊻ addmask, mask ⊻ addmask)
        result
    end
    Base.:(|)(a::Integer, b::Masked{Boolean}) = Base.:(|)(b, a)

    function Base.:(|)(a::Masked{Boolean}, b::Masked{Boolean})
        #      (a.val ⊻ a.mask)   |   (b.val ⊻ b.mask))
        # = ~(~(a.val ⊻ a.mask)   &  ~(b.val ⊻ b.mask))
        ~(~a & ~b)
    end

    function Base.mod(a::Masked{Boolean}, b::Integer)
        # This assertion is needed, since otherwise our reduction (mod b) does not work.
        @assert ispow2(b)

        a & (b-1)
    end

    function Base.:(==)(a::Masked{Boolean}, b::Masked{Boolean})
        # a.val ⊻ a.mask == b.val ⊻ b.mask
        # a.val ⊻ b.mask == b.val ⊻ a.mask
        a.val ⊻ b.mask == b.val ⊻ a.mask
    end