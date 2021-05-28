"""
The DPA module implements generic **D**ifferential **P**ower **A**ttacks. The implementation largely follows the one described by Kocher in [this paper](https://link.springer.com/article/10.1007/s13389-011-0006-y), but is generalized to support other cryptographic algorithms.

A detailed documentation can be found at [DPA](@ref)
"""
module DPA

using CryptoSideChannel
using StaticArrays
using Plots
using Profile
using Distributions
using CryptoSideChannel.Logging
using CryptoSideChannel.AES

"""
    function sample_AES_power_trace(key, input)

Returns a AES power trace generated with `key` on `input`. The trace contains the Hamming weight of all intermediate values.
"""
function sample_AES_power_trace(key, input)
    global coll = []
    closure = () -> coll
    key = map(x -> Logging.HammingWeightLog(x, closure), key)
    input = map(x -> Logging.HammingWeightLog(x, closure), input)
    AES.AES_encrypt(input, key)
    return copy(coll)
end

function sample_AES_power_trace_noise(key, input)
    global coll
    coll = []
    clos = () -> coll
    d = Distributions.Normal(-4, 3)

    reduce_function = x -> Base.count_ones(x) + rand(d)

    kl = map(x -> Logging.SingleFunctionLog(x, clos, reduce_function), key)
    ptl = map(x -> Logging.SingleFunctionLog(x, clos, reduce_function), input)

    AES.AES_encrypt(ptl, kl)

    return copy(coll)
end

"""
    function select(plaintext, key_guess, key_guess_index)::Bool

Decides in which partition a trace with input `plaintext` should fall when the `key_guess_index`-th key byte is set to `key_guess`.

# Arguments
- `plaintext`: The text that was the input for the recorded power trace.
- `key_guess_index`: The targeted AES key byte.
- `key_guess`: The current guess for the targeted key byte.

# Returns
True if the trace belongs to the first partition. False if the trace should belong to the second partition.
"""
function DPA_AES_select(plaintext, key_guess, key_guess_index)::Bool
#    return Base.count_ones(AES.c_sbox[(trace[1][key_guess_index] ⊻ key_guess)+1]) >= 4
    return AES.c_sbox[(plaintext[key_guess_index] ⊻ key_guess)+1] & 1
end

function generate_difference_trace(plaintexts, traces, select, guess, position)
    traces_zero = zeros(size(traces, 1))
    num_traces_zero = 0
    traces_one = zeros(size(traces, 1))
    num_traces_one = 0
    for trace_nr = 1:size(traces, 2)
        plaintext = plaintexts[trace_nr]
        trace = traces[:, trace_nr]
        if select(plaintext, guess, position)
            traces_one .+= trace
            num_traces_one += 1
        else
            traces_zero .+= trace
            num_traces_zero += 1
        end
    end
    @assert num_traces_one > 0 && num_traces_zero > 0

    traces_one ./= convert(Float64, num_traces_one)
    traces_zero ./= convert(Float64, num_traces_zero)

    diff = abs.(traces_one .- traces_zero)
    #diff = (traces_one .- traces_zero)
    diff
end

# Sample function must take an AES input MVector{16, UInt8} and return an array of Integers
"""
    DPA_AES_analyze(sample_function; N = 2^12)

Performs a DPA attack against AES, where traces are collected from a specified function.

# Arguments
- `sample_function`: single-argument function that takes an input AES input (`MVector{16, UInt8}`) and returns a power trace as an array of numbers for this input.
- `N`: the number of traces to collect before performing the attack. Defaults to ``2^12``

# Returns
The recovered AES key

# Example
```julia-repl
julia> test_key = hex2bytes("00112233445566778899aabbccddeeff");
julia> sample_function(x) = DPA.sample_AES_power_trace(test_key, x);
julia> recovered_key = DPA.DPA_AES_analyze(sample_function);
[...]
julia> print(recovered_key)
UInt8[0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff]
```
"""
function DPA_AES_analyze(sample_function; N = 2^12)
    # choose random plaintexts.
    plaintexts = [MVector{16}(rand(UInt8, 16)) for _=1:N]

    # traces are stored column major: at position traces[:,i] the i-th trace is stored
    traces = zeros(length(sample_function(plaintexts[1])), length(plaintexts))
    for x = 1:length(plaintexts)
        traces[:,x] = sample_function(plaintexts[x])
    end
    DPA_AES_analyze_traces(plaintexts, traces)
end

"""
    DPA_AES_analyze_traces(plaintexts::Vector, traces::Matrix, power_estimate)

Performs a DPA attack against AES on given traces.

# Arguments
- `plaintexts`: A vector of size `N`, where `N` is the number of power traces sampled.
- `traces`: A matrix of size `M * N`, where `M` is the number of samples per trace. Power traces are stored in column-major order, i.e. it is expected that `traces[:,i]` refers to the powertrace generated with `plaintexts[i]`

# Returns
The recovered AES key.
"""
function DPA_AES_analyze_traces(plaintexts::Vector, traces::Matrix)
    completeKey = []
    for idx = 1:16
        keyGuesses = []
        for k::UInt8 = 0x0:0xFF
            diff = generate_difference_trace(plaintexts, traces, DPA_AES_select, k, idx)
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

end

