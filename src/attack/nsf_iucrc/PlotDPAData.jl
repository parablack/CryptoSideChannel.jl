

include("ParseData.jl")

"""
hamming_distance_power_estimate(ciphertext, key_guess_index, key_guess)

A power estimation function targeting the last round of AES under the Hamming distance model, suitable for the real-word data provided. For more information on power estimation, see the [main section](@ref power_estimation_function).
"""
function hamming_distance_power_estimate(ciphertext, key_guess_index, key_guess)
    state = permutedims(reshape(ciphertext, 4, 4), [2,1])
    AES.shift_rows!(state)

    final_state = state[((key_guess_index - 1) ÷ 4) + 1, ((key_guess_index - 1) % 4) + 1]
    AES.inv_shift_rows!(state)
    state[((key_guess_index - 1) ÷ 4) + 1, ((key_guess_index - 1) % 4) + 1] ⊻= key_guess
    AES.inv_sub_bytes!(state)
    preround_state = state[((key_guess_index - 1) ÷ 4) + 1, ((key_guess_index - 1) % 4) + 1]
    Base.count_ones(preround_state ⊻ final_state) >= 4
end

function attack(; number_of_traces = 7000)
    @time begin
        println("Parsing $(number_of_traces) traces.")

        inputs = parse_input_file("/run/media/simon/D-Platte/Uni/aes/001_cipher.txt", number_of_traces)
        traces = parse_trace_file("/run/media/simon/D-Platte/Uni/aes/001_trace_int.txt", number_of_traces)
    end
    println("Parsing completed, starting attack")

    @assert length(inputs) == size(traces, 2)

    @time begin
    last_round_key = CPA.CPA_AES_analyze_manual(inputs, traces, hamming_distance_power_estimate)
    aes_128_key = AES.inv_key_expand(last_round_key)[1:16]
    end

end

#    attack()

#   using Statistics
#   function perf_test()
#       hypo = zeros(length(plaintexts))
#
#       completeKey = []
#
#       for idx = 1:1
#           keyGuesses = []
#           rightcorplt = []
#           wrongcorplt = []
#           for k::UInt8 = 0x0:0xFF
#               for plaintext::UInt = 1:length(plaintexts)
#                   # Hypothesis under key k (at position idx)
#                   hypo[plaintext] = hd_power_estimate(plaintexts[plaintext], idx, k)
#               end
#               best_corr = 0.0
#               corr = Statistics.cor(hypo, traces, dims=2)
#               best_corr = maximum(abs.(corr))
#               push!(keyGuesses, (best_corr, k))
#           end
#       end
#   end

# using Profile
# @time perf_test()
