"""
This struct merges different key bytes for which probabilities are known to a whole key, by iterating first over keys that are more likely.

Keys are stored as lists of lists, where the outer lists represent the respective key byte (i.e. the first list represents the first key byte). The inner lists must be sorted according to the probability of a specific byte occuring.
"""
struct LikelyKey
    keylist::Vector{Vector{Integer}}
end

"""
    Base.iterate(k::LikelyKey)
    Base.iterate(k::LikelyKey, state::Stack{Int})

Iterate over a LikelyKey. Keys that are more likely by the internal sorting of `k` will be iterated first.

Internally, the current status of the iteration is represented by a stack. The contents of this stack are indices of the outer list. An occurence of a list index means that at this position in the key the next likely value should be tried.
For example, a stack containing the following values:
`[1, 1, 1, 3, 3, 4, 4, 5]` would be interpreted as follows:
- For the first key byte, take the fourth most likely (since there are three 1s in our stack, we take the 3+1th most likely element)
- The second key byte is the most likely (since there is no 2 in our stack)
- The third key byte is the third most likely (there are two 3s in our stack)
- Same for the fourth key byte: Take the third most likely
- For the fifth key byte, take the second most likely (there is one 5 in our stack)

With this system, stacks with less entries will always correspond to more likely lists than stacks containing more entries.
"""
function Base.iterate(k::LikelyKey)
    return (map(x -> x[1], k.keylist), Stack{Int}())
end

"""
    function increase!(s::Stack{Int}, size::Int)

Modifies the stack to the next larger state. All stacks that contain `n` elements will be seen before any stack containing `n + 1` elements. No element in the stack will be greater than `size`.

If results from this method are used with `iterate`, all lists will be iterated.

# Internals
If `s` has `n` elements, and there is a lexicographically larger stack with `n` elements, return a lexicographically larger stack corresponding to a new list (as descriped in [iterate](@ref)).

Otherwise, returns the lexicographically smallest stack with `n+1` elements.
"""
function increase!(s::Stack{Int}, size::Int)
    if isempty(s)
        push!(s, 1)
        return
    end
    last = pop!(s)
    if last < size
        push!(s, last + 1)
        return
    end
    increase!(s, size)
    push!(s, first(s))
end


function Base.iterate(k::LikelyKey, state::Stack{Int})
    increase!(state, length(k.keylist))
    retList = zeros(typeof(k.keylist[1][1]), length(k.keylist))
    iter = Iterators.reverse(state)
    it = iterate(iter)
    for j = 1:length(k.keylist)
        idx = 1
        while it !== nothing && it[1] == j
            idx += 1
            it = iterate(iter, it[2])
        end
        if idx > length(k.keylist[j])
            if length(state) > length(k)
                return nothing
            end
            return iterate(k, state)
        end
        retList[j] = k.keylist[j][idx]
    end
    retList, state
end

Base.length(k::LikelyKey) = prod(map(length, k.keylist))
Base.eltype(k::LikelyKey) = Vector{typeof(k.keylist[1][1])}
