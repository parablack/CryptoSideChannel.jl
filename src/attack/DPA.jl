
module DPA
    using CSC.AES
    using CSC
    using StaticArrays
    using Plots
    using Profile

    function sample_power_trace(key, input)
        coll = []
        key = map(x -> HammingWeightLog(x, coll), key)
        input = map(x -> HammingWeightLog(x, coll), input)
        AES.AES_encrypt(input, key)
        coll
    end

    function select(trace, key_guess, key_guess_index)::Bool
        return Base.count_ones(AES.c_sbox[(trace[1][key_guess_index] ⊻ key_guess)+1]) >= 4
    end

    function generate_difference_trace(traces, select, guess, position)
        traces_zero = map(y -> y[2], filter(x -> select(x, guess, position), traces))
        traces_one = map(y -> y[2], filter(x -> !select(x, guess, position), traces))
        traces_zero = hcat(traces_zero...)
        traces_one = hcat(traces_one...)
        avg_one = [sum(traces_one[b,:])/size(traces_one, 2) for b in 1:size(traces_one, 1)]
        avg_zero = [sum(traces_zero[b,:])/size(traces_zero, 2) for b in 1:size(traces_zero, 1)]
        diff = abs.(avg_one .- avg_zero)
        diff
    end

    # Sample function must take an AES input MVector{16, UInt8} and return an array of Integers
    function DPA_AES_analyze(sample_function)
        # sample traces
        traces = [MVector{16}(rand(UInt8, 16)) for _=1:2^8]
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
end

