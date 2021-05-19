using StaticArrays
using Plots
using CryptoSideChannel.CPA
using CryptoSideChannel.AES
using Distributions
using Statistics

test_key = (hex2bytes("42112233445566778899aabbccddeeff"))
d = Distributions.Normal(0, 1)
sample_function(x) = CPA.sample_power_trace(test_key, x, x -> Base.count_ones(x) + rand(d))

plaintexts = [MVector{16}(rand(UInt8, 16)) for _=1:2^10]
hypo = zeros(length(plaintexts))
hypo2 = zeros(length(plaintexts))

# traces are stored column major: at position traces[:,i] the i-th trace is stored
traces = zeros(length(sample_function(plaintexts[1])), length(plaintexts))
for x = 1:length(plaintexts)
    traces[:,x] = sample_function(plaintexts[x])
end


power_estimate(plaintext, key_guess_index, key_guess) = Base.count_ones(AES.c_sbox[(plaintext[key_guess_index] ⊻ key_guess)+1])

idx = 1
k = 0x42
for plaintext::UInt = 1:length(plaintexts)
    # Hypothesis under key k (at position idx)
    hypo[plaintext] = power_estimate(plaintexts[plaintext], idx, k)
end
corrcorrect = Statistics.cor(hypo, traces, dims=2)'

k = 0x43
for plaintext::UInt = 1:length(plaintexts)
    # Hypothesis under key k (at position idx)
    hypo2[plaintext] = power_estimate(plaintexts[plaintext], idx, k)
end
corrwrong = Statistics.cor(hypo2, traces, dims=2)'


plt = plot([corrcorrect, corrwrong], label=["Correct key (k = 0x42)" "Incorrect key (k = 0x43)"], xlabel="Time", ylabel="Correlation ρ", yrange=(-1, 1))
display(plt)
png(plt, "cpa_correlation_two_keys_over_time.png")

strongcorr = argmax(abs.(corrcorrect))

plt = plot([traces[strongcorr,:], hypo], label=["Measured data" "Power prediction for correct key (k = 0x42)"], xlabel="Trace Nr.", ylabel="Side-channel value")
display(plt)
png(plt, "cpa_trace_prediction_at_sbox_lookup.png")
print("Rho=")
display(maximum(abs.(corrcorrect)))