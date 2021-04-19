"""
    The DPA module implements **D**ifferential **P**ower **A**ttacks against AES, as described by Kocher in [this paper](https://link.springer.com/article/10.1007/s13389-011-0006-y).

    A detailed documentation can be found at [DPA](@ref)
"""
module DPA

using CryptoSideChannel
using StaticArrays
using Plots
using Profile

function sample_power_trace(key, input)
    global coll = []
    closure = () -> coll
    key = map(x -> Logging.HammingWeightLog(x, closure), key)
    input = map(x -> Logging.HammingWeightLog(x, closure), input)
    AES.AES_encrypt(input, key)
    coll
end

function select(trace, key_guess, key_guess_index)::Bool
    return Base.count_ones(AES.c_sbox[(trace[1][key_guess_index] ⊻ key_guess)+1]) >= 4
end

function generate_difference_trace(traces, select, guess, position)
    traces_zero = zeros(size(traces[1][2]))
    num_traces_zero = 0
    traces_one = zeros(size(traces[1][2]))
    num_traces_one = 0
    for trace = traces
        if select(trace, guess, position)
            traces_one .+= trace[2]
            num_traces_one += 1
        else
            traces_zero .+= trace[2]
            num_traces_zero += 1
        end
    end
    @assert num_traces_one > 0 && num_traces_zero > 0

    traces_one ./= convert(Float64, num_traces_one)
    traces_zero ./= convert(Float64, num_traces_zero)

    diff = abs.(traces_one .- traces_zero)
    diff
end

# Sample function must take an AES input MVector{16, UInt8} and return an array of Integers
function DPA_AES_analyze(sample_function)
    # sample traces
    traces = [MVector{16}(rand(UInt8, 16)) for _=1:2^7]
    traces = map(x -> (x, sample_function(x)), traces)
    completeKey = []
    for idx = 1:16
        keyGuesses = []
        for k::UInt8 = 0x0:0xFF
            diff = generate_difference_trace(traces, select, k, idx)
            corr = maximum(diff)
            push!(keyGuesses, (corr, k))
            # display(plot(diff))
        end
        sort!(keyGuesses, rev=true)

        println("Best: $(keyGuesses[1][2]) correlates $(keyGuesses[1][1]). Snd: $(keyGuesses[2][2]) correlates $(keyGuesses[2][1])")
        push!(completeKey, keyGuesses[1][2])

        #traceBest = generate_difference_trace(traces, select, keyGuesses[1][2], 1)
        #traceSnd = generate_difference_trace(traces, select, keyGuesses[2][2], 1)
        #plt = (plot([traceBest, traceSnd], label=["Correct Key (k = $(keyGuesses[1][2]))" "Second best #correlation (k = $(keyGuesses[2][2]))"]))
        #png(plt, "dpa_hamming_compare_best_traces.png")

    end
    completeKey = convert(Vector{UInt8}, completeKey)
    return completeKey

end

#  test_key = (hex2bytes("41112233445566778899aabbccddeeff"))
#  sample_function(x) = sample_power_trace(test_key, x)
#  traces = [MVector{16}(rand(UInt8, 16)) for _=1:2^16]
#  traces = map(x -> (x, sample_function(x)), traces)
#  diff = @profile generate_difference_trace(traces, select, 1, 1)
#print(diff)
#  recovered_key = DPA_AES_analyze(sample_function)

end

