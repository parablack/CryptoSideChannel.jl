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
"""
function Base.iterate(k::LikelyKey)
    return (map(x -> x[1], k.keylist), Stack{Int}())
end

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
