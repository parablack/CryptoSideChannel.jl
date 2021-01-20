
module CPA
    using CSC.AES
    using CSC
    using CSC.Logging
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
    # - hypothesis: Takes a plaintext, a key index, and a key guess and returns an hypothesis of power consumption on a specific timepoint
    function CPA_AES_analyze(sample_function, hypothesis)
        # choose random plaintexts.
        plaintexts = [MVector{16}(rand(UInt8, 16)) for _=1:2^8]

        # traces are stored column major: at position traces[i,:] the i-th trace is stored
        traces = zeros(length(plaintexts), length(sample_function(plaintexts[1])))
        for x = 1:length(plaintexts)
            traces[x,:] = sample_function(plaintexts[x])
        end

        # Hypothesis of power consumption under specific guess
        hypo = zeros(length(plaintexts))

        completeKey = []

        for idx = 1:16
            keyGuesses = []
            for k::UInt8 = 0x0:0xFF
                for plaintext::UInt = 1:length(plaintexts)
                    # Hypothesis under key k (at position idx)
                    hypo[plaintext] = hypothesis(plaintexts[plaintext], idx, k)
                end
                best_corr = 0.0
                for trace_pos::UInt = 1:(size(traces, 2))
                    # Correlation between hypothesis and key at each point of time. Optimally (if data is not noisy), we reach a correlation of 1
                    corr = Statistics.cor(hypo, traces[:,trace_pos])
                    # corr is Nan if traces[:,traces_pos] is constant. This can only be the case if it did not depend on k, so we can skip this value
                    if isnan(corr)
                       continue
                    end
                    best_corr = max(best_corr, abs(corr))
                end
                push!(keyGuesses, (best_corr, k))

            end
            sort!(keyGuesses, rev=true)
            push!(completeKey, keyGuesses[1][2])

            #println("Best: $(keyGuesses[1][2]) correlates $(keyGuesses[1][1]). Snd: $(keyGuesses[2][2]) correlates $(keyGuesses[2][1])")

            #_plot(keyGuesses)

        end
        completeKey = convert(Vector{UInt8}, completeKey)
        return completeKey

    end

end

