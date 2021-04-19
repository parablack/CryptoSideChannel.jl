"""
    The CPA module implements **C**orrelation **P**ower **A**ttacks against AES.

    More documentation is available at [CPA](@ref)
"""
module CPA

using CryptoSideChannel
using Statistics
using StaticArrays
using Plots

function _plot(result)
    arr = zeros(256)
    for k = result
        arr[k[2]+1] = k[1]
    end
    plt = (plot([arr], label="Maximal Pearson correlation for key"))
    png(plt, "cpa_hamming_compare_all_keys_noise_8.png")
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

# Sample Hypothesis function:
#function hypothesis(plaintext, key_guess_index, key_guess)::UInt8
#    return Base.count_ones(AES.c_sbox[(plaintext[key_guess_index] ⊻ key_guess)+1])
#end

# Sample function must take an AES input MVector{16, UInt8} and return an array of Integers
# We expect:
# - sample_function: Takes an input and returns a power trace for this input
# - power_estimate: Takes a plaintext, a key index, and a key guess and returns an hypothesis of power consumption on a specific timepoint
function CPA_AES_analyze(sample_function, power_estimate)
    # choose random plaintexts.
    plaintexts = [MVector{16}(rand(UInt8, 16)) for _=1:2^10]

    # traces are stored column major: at position traces[:,i] the i-th trace is stored
    traces = zeros(length(sample_function(plaintexts[1])), length(plaintexts))
    for x = 1:length(plaintexts)
        traces[:,x] = sample_function(plaintexts[x])
    end


    CPA_AES_analyze_traces(plaintexts, traces, power_estimate)

end


"""
    CPA_AES_analyze_traces(plaintexts::Vector, traces::Matrix, power_estimate)

Returns the most likely key used during an AES encryption of the inputs in `plaintexts`, where each input produced a power trace from `traces`.

# Arguments
- `plaintexts`: A Vector of size `N`, where `N` is the number of power traces sampled.
- `traces`: A Matrix of size `M * N`, where `M` is the number of samples per trace.
 Power traces are stored in column-major order, i.e. it is expected that `traces[i,:]` refers
 to the powertrace generated with `plaintexts[i]`
- power_estimate: A function that takes a `plaintext::MVector{16, UInt6}`, a key index (1 <= `key_guess_index` <= 16), and a key guess (0 <= `key_guess` <= 255) and returns an hypothesis of power consumption
    For example, a power estimator that simply takes Hamming Weight into account would look like this:
    ```power_estimate(plaintext, key_guess_index, key_guess) = Base.count_ones(AES.c_sbox[(plaintext[key_guess_index] ⊻ key_guess)+1])
    ```
"""
function CPA_AES_analyze_traces(plaintexts::Vector, traces::Matrix, power_estimate)
    @assert size(plaintexts, 1) == size(traces, 2)

    # Hypothesis of power consumption under specific guess
    hypo = zeros(length(plaintexts))

    completeKey = []

    for idx = 1:16
        keyGuesses = []
        rightcorplt = []
        wrongcorplt = []
        for k::UInt8 = 0x0:0xFF
            for plaintext::UInt = 1:length(plaintexts)
                # Hypothesis under key k (at position idx)
                hypo[plaintext] = power_estimate(plaintexts[plaintext], idx, k)
            end
            best_corr = 0.0
            corr = Statistics.cor(hypo, traces, dims=2)
            best_corr = maximum(abs.(corr))
            push!(keyGuesses, (best_corr, k))
        end
#            if idx == 1
#                plt = (plot([rightcorplt, wrongcorplt], label=["Pearson correlation for correct key" "Pearson correlation for wrong key"], xlabel="Time", ylabel="Pearson correlation coefficient"))
#                png(plt, "cpa_hamming_max_corr_over_time.png")
#            end
        sort!(keyGuesses, rev=true)
        push!(completeKey, keyGuesses[1][2])

        println("Best: $(string(keyGuesses[1][2], base=16)) correlates $(keyGuesses[1][1]). Snd: $(string(keyGuesses[2][2], base=16)) correlates $(keyGuesses[2][1])")

        #_plot(keyGuesses)

    end
    completeKey = convert(Vector{UInt8}, completeKey)
    return completeKey

end


using Distributions
function test_hamming_noise()
    test_key = (hex2bytes("012788e0999ec84cbeb959cffeaaf2e7"))
    d = Distributions.Normal(0, 4)
    sample_function(x) = CPA.sample_power_trace(test_key, x, x -> Base.count_ones(x) + rand(d))
    hypothesis(plaintext, key_guess_index, key_guess) = Base.count_ones(AES.c_sbox[(plaintext[key_guess_index] ⊻ key_guess)+1])
    recovered_key = CPA.CPA_AES_analyze(sample_function, hypothesis)
#        recovered_key
end
#    test_hamming_noise()

include("nsf_iucrc/UnmaskedAttack.jl")

end

