"""
The CPA module implements generic **C**orrelation **P**ower **A**ttacks.

More documentation is available at [CPA](@ref)
"""
module CPA

using CryptoSideChannel
using CryptoSideChannel.Logging
using CryptoSideChannel.AES
using CryptoSideChannel.SPECK
using Statistics
using StaticArrays
using Plots

function _plot(result)
    arr = zeros(256)
    for k = result
        arr[k[2]+1] = k[1]
    end
    plt = plot([arr], label="Maximal ρ for key at any timepoint", xlabel="Key candidate", ylabel="Correlation ρ")
    png(plt, "cpa_hamming_compare_all_keys_noise_45.png")
    display(plt)
end

function sample_power_trace(key, input, reduce_function)
    global coll = []
    closure = () -> coll
    key = map(x -> Logging.SingleFunctionLog(x, closure, reduce_function), key)
    input = map(x -> Logging.SingleFunctionLog(x, closure, reduce_function), input)
    AES.AES_encrypt(input, key)
    coll
end

"""
    CPA_AES_analyze(sample_function, leakage_model)

Performs a CPA attack against AES, where traces are collected from a specified function.

# Arguments
- `sample_function`: single-argument function that takes an input AES input (`MVector{16, UInt8}`) and returns a power trace as an array of numbers for this input.
- `leakage_model`: a function reducing a processed value ``R`` to their estimated side-channel emissions ``W_R``

# Returns
The recovered AES key
"""
function CPA_AES_analyze(sample_function, leakage_model; N = 2^12)
    # choose random plaintexts.
    plaintexts = [MVector{16}(rand(UInt8, 16)) for _=1:N]

    # traces are stored column major: at position traces[:,i] the i-th trace is stored
    traces = zeros(length(sample_function(plaintexts[1])), length(plaintexts))
    for x = 1:length(plaintexts)
        traces[:,x] = sample_function(plaintexts[x])
    end
    CPA_AES_analyze_traces(plaintexts, traces, leakage_model)

end

"""
    CPA_AES_analyze_manual(plaintexts::Vector, traces::Matrix, leakage_model)

Performs a CPA attack against AES on given traces.

# Arguments
- `plaintexts`: A vector of size `N`, where `N` is the number of power traces sampled.
- `traces`: A matrix of size `M * N`, where `M` is the number of samples per trace. Power traces are stored in column-major order, i.e. it is expected that `traces[:,i]` refers to the powertrace generated with `plaintexts[i]`
- `leakage_model`: a function reducing a processed value ``R`` to their estimated side-channel emissions ``W_R``

# Returns
The recovered AES key
"""
function CPA_AES_analyze_traces(plaintexts::Vector, traces::Matrix, leakage_model)
    # target the first S-Box output:
    power_estimate(plaintext, key_guess_index, key_guess) = leakage_model(AES.c_sbox[(plaintext[key_guess_index] ⊻ key_guess)+1])

    CPA_AES_analyze_manual(plaintexts, traces, power_estimate)
end

"""
    CPA_AES_analyze_manual(plaintexts::Vector, traces::Matrix, power_estimate)

Performs a CPA attack against AES on given traces.

# Arguments
- `plaintexts`: A vector of size `N`, where `N` is the number of power traces sampled.
- `traces`: A matrix of size `M * N`, where `M` is the number of samples per trace. Power traces are stored in column-major order, i.e. it is expected that `traces[:,i]` refers to the powertrace generated with `plaintexts[i]`
- `power_estimate`: A function that takes a `plaintext::MVector{16, UInt6}`, a key index (1 <= `key_guess_index` <= 16), and a key guess (0 <= `key_guess` <= 255) and returns an hypothesis on power consumption.
    For example, a classical implementation of this function for AES with Hamming weight would be
    ```
    power_estimate(plaintext, key_guess_index, key_guess) =
        Base.count_ones(AES.c_sbox[(plaintext[key_guess_index] ⊻ key_guess)+1])
    ```
"""
function CPA_AES_analyze_manual(plaintexts::Vector, traces::Matrix, power_estimate)
    @assert size(plaintexts, 1) == size(traces, 2)

    # Hypothesis of power consumption under specific guess
    hypo = zeros(length(plaintexts))

    #aespower_estimate(plaintext, key_guess_index, key_guess) =
    #    power_estimate(AES.c_sbox[(plaintext[key_guess_index] ⊻ key_guess)+1])

    completeKey = []

    for idx = 1:16
        keyGuesses = []
#        wrongcorplt = []
#        rightcorplt = []
        for k::UInt8 = 0x00:0xFF
            for plaintext::UInt = 1:length(plaintexts)
                # Hypothesis under key k (at position idx)
                hypo[plaintext] = power_estimate(plaintexts[plaintext], idx, k)
            end
            best_corr = 0.0
            corr = Statistics.cor(hypo, traces, dims=2)
#            if idx == 1 && k == 0x13
#                rightcorplt = copy(transpose(corr))
#            end
#            if idx == 1 && k == 0x42
#                wrongcorplt = copy(transpose(corr))
#            end

            best_corr = maximum(abs.(filter(!isnan, corr)))
            push!(keyGuesses, (best_corr, k))
        end
#        if idx == 1
#                plt = plot(eachindex(rightcorplt), [rightcorplt, wrongcorplt], label=["Correct key (k = 0x13)" "Incorrect key (k = 0x42)"], xlabel="Time", ylabel="Correlation ρ", yrange=(-0.115, 0.115))
#                png(plt, "cpa_realworld_max_corr_over_time.png")
#        end
        sort!(keyGuesses, rev=true)
        push!(completeKey, keyGuesses[1][2])

        println("Best: $(string(keyGuesses[1][2], base=16)) correlates $(keyGuesses[1][1]). Snd: $(string(keyGuesses[2][2], base=16)) correlates $(keyGuesses[2][1])")

        #_plot(keyGuesses)

    end
    completeKey = convert(Vector{UInt8}, completeKey)
    return completeKey
end


"""
    sample_SPECK_power_trace(key, input, reduce_function)

Collects a power trace of SPECK with a given key of type `(UInt64, UInt64)` and input of type `(UInt64, UInt64)`. The resulting power trace is reduced with `reduce_function`.
"""
function sample_SPECK_power_trace(key::Tuple{T, T}, input::Tuple{T, T}, reduce_function) where T
    global coll = []
    closure = () -> coll
    key = map(x -> Logging.SingleFunctionLog(x, closure, reduce_function), key)
    input = map(x -> Logging.SingleFunctionLog(x, closure, reduce_function), input)
    SPECK.SPECK_encrypt(input, key)
    coll
end


function CPA_SPECK_power_right_key(pt::Tuple{T, T}, key_guess_index::Int, key_guess, leakage_model) where T
    temp         = Base.bitrotate(pt[1], -8)
    p1           = temp + pt[2]
    intermediate = (p1 >> (key_guess_index * 8)) & 255
    intermediate ⊻= key_guess
    return leakage_model(intermediate)
end
function CPA_SPECK_power_round_key(pt::Tuple{T, T}, k2, key_guess_index::Int, key_guess, leakage_model) where T
    temp         = Base.bitrotate(pt[1], -8)
    p1           = temp + pt[2]
    r1           = p1 ⊻ k2
    temp         = Base.bitrotate(pt[2], 3)
    s1           = temp ⊻ r1
    temp         = Base.bitrotate(r1, -8)
    p2           = temp + s1
    intermediate = (p2 >> (key_guess_index * 8)) & 255
    intermediate ⊻= key_guess
    return leakage_model(intermediate)
end

@doc raw"""
    CPA_SPECK_analyze(sample_function)

Performs a CPA attack against SPECK.

# Arguments
- `sample_function`: a single-argument function that takes a SPECK input (`Tuple{UInt64, UInt64}`) and returns a power trace (array of numbers) for this input.
- `leakage_model`: a function reducing a processed value ``R`` to their estimated side-channel emissions ``W_R``
- `N`: the amount of traces to collect

# Returns
The reconstructed SPECK key as a `Tuple{UInt64, UInt64}`
"""
function CPA_SPECK_analyze(sample_function, leakage_model; N = 2^12)
    # choose random plaintexts.
    plaintexts = [(rand(UInt64), rand(UInt64)) for _=1:N]

    # traces are stored column major: at position traces[:,i] the i-th trace is stored
    traces = zeros(length(sample_function(plaintexts[1])), length(plaintexts))
    for x = 1:length(plaintexts)
        traces[:,x] = sample_function(plaintexts[x])
    end
    CPA_SPECK_analyze_traces(plaintexts, traces, leakage_model)

end

"""
    CPA_SPECK_analyze_traces(plaintexts::Vector, traces::Matrix, leakage_model)

Perform a CPA attack against SPECK on the provided traces.

# Arguments
- `plaintexts`: A Vector of size `N`, where `N` is the number of power traces sampled.
- `traces`: A Matrix of size `M * N`, where `M` is the number of samples per trace.
 Power traces are stored in column-major order, i.e. it is expected that `traces[i,:]` refers
 to the powertrace generated with `plaintexts[i]`
- `leakage_model`: a function reducing a processed value ``R`` to their estimated side-channel emissions ``W_R``

# Returns
The reconstructed SPECK key as a `Tuple{UInt64, UInt64}`
"""
function CPA_SPECK_analyze_traces(plaintexts::Vector, traces::Matrix, leakage_model)
    @assert size(plaintexts, 1) == size(traces, 2)

    # Hypothesis of power consumption under specific guess
    hypo = zeros(length(plaintexts))

    completeKey = []
    # Right half key
    for idx = 0:7
        keyGuesses = []
        for k::UInt8 = 0x01:0xFF
            for plaintext::UInt = 1:length(plaintexts)
                # Hypothesis under key k (at position idx)
                hypo[plaintext] = CPA_SPECK_power_right_key(plaintexts[plaintext], idx, k, leakage_model)
            end
            best_corr = 0.0
            corr = Statistics.cor(hypo, traces, dims=2)
            best_corr = maximum((corr))
            push!(keyGuesses, (best_corr, k))
        end

        #plt = plot(1:255, x -> keyGuesses[x][1], xlabel="Key candidate", ylabel="Maximal correlation ρ", label="")
        #display(plt)
        #savefig("cpa_speck_key_candidates.png")
        sort!(keyGuesses, rev=true)
        push!(completeKey, keyGuesses[1][2])
        println("[Right key] Best: $(string(keyGuesses[1][2], base=16)) correlates $(keyGuesses[1][1]). Snd: $(string(keyGuesses[2][2], base=16)) correlates $(keyGuesses[2][1])")

        #_plot(keyGuesses)

    end
    rightKey = zero(UInt64)
    for x = Iterators.reverse(completeKey)
        rightKey <<= 8
        rightKey |= x
    end
    println("Reconstructed right key = $(string(rightKey, base=16))")

    ## Reconstruct round key used for SPECK
    completeKey = []

    for idx = 0:7
        keyGuesses = []
        for k::UInt8 = 0x01:0xFF
            for plaintext::UInt = 1:length(plaintexts)
                # Hypothesis under key k (at position idx)
                hypo[plaintext] = CPA_SPECK_power_round_key(plaintexts[plaintext], rightKey, idx, k, leakage_model)
            end
            best_corr = 0.0
            corr = Statistics.cor(hypo, traces, dims=2)
            best_corr = maximum((corr))
            push!(keyGuesses, (best_corr, k))
        end

        #plt = plot(1:255, x -> keyGuesses[x][1], xlabel="Key candidate", ylabel="Maximal correlation ρ", label="")
        #display(plt)
        #savefig("cpa_speck_key_candidates.png")
        sort!(keyGuesses, rev=true)
        push!(completeKey, keyGuesses[1][2])
        println("[Round Key] Best: $(string(keyGuesses[1][2], base=16)) correlates $(keyGuesses[1][1]). Snd: $(string(keyGuesses[2][2], base=16)) correlates $(keyGuesses[2][1])")

        #_plot(keyGuesses)

    end

    roundKey = zero(UInt64)
    for x = Iterators.reverse(completeKey)
        roundKey <<= 8
        roundKey |= x
    end

    println("Reconstructed round key = $(string(roundKey, base=16))")

    ## Reconstruct original key from right and round key:
    T1 = roundKey ⊻ Base.bitrotate(rightKey, 3)
    T2 = T1 - rightKey
    leftKey = Base.bitrotate(T2, 8)

    println("Reconstructed left key = $(string(leftKey, base=16))")
    println("SPECK key $(string(leftKey, base=16)) $(string(rightKey, base=16))")

    return (leftKey, rightKey)
end
end

