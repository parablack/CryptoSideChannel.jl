using CSC.CPA, CSC.AES
using Test, StaticArrays
using Distributions


function test_hamming_weight()
    test_key = (hex2bytes("41112233445566778899aabbccddeeff"))
    sample_function(x) = CPA.sample_power_trace(test_key, x, Base.count_ones)
    hypothesis(plaintext, key_guess_index, key_guess) = Base.count_ones(AES.c_sbox[(plaintext[key_guess_index] ⊻ key_guess)+1])
    recovered_key = CPA.CPA_AES_analyze(sample_function, hypothesis)

    @test test_key == recovered_key
end

function test_lsb()
    test_key = (hex2bytes("63f5f4aa80c2c61ae31e8ab9df24ebd4"))
    sample_function(x) = CPA.sample_power_trace(test_key, x, x -> (x) & 1)
    hypothesis(plaintext, key_guess_index, key_guess) = 0x1 & (AES.c_sbox[(plaintext[key_guess_index] ⊻ key_guess)+1])
    recovered_key = CPA.CPA_AES_analyze(sample_function, hypothesis)
    @test test_key == recovered_key
end

function test_msb()
    test_key = (hex2bytes("ab7a2656ee8e4cb06b6cb98df814c6f6"))
    sample_function(x) = CPA.sample_power_trace(test_key, x, x -> (x>>>7) & 1)
    hypothesis(plaintext, key_guess_index, key_guess) = 0x1 & ((AES.c_sbox[(plaintext[key_guess_index] ⊻ key_guess)+1]) >>> 7)
    recovered_key = CPA.CPA_AES_analyze(sample_function, hypothesis)
    @test test_key == recovered_key
end

function test_hamming_noise()
    test_key = (hex2bytes("042788e0999ec84cbeb959cffeaaf2e7"))
    d = Distributions.Normal(0, 2)
    sample_function(x) = CPA.sample_power_trace(test_key, x, x -> Base.count_ones(x) + rand(d))
    hypothesis(plaintext, key_guess_index, key_guess) = Base.count_ones(AES.c_sbox[(plaintext[key_guess_index] ⊻ key_guess)+1])
    recovered_key = CPA.CPA_AES_analyze(sample_function, hypothesis)
    @test test_key == recovered_key
end


test_hamming_weight()
test_lsb()
test_msb()
test_hamming_noise()