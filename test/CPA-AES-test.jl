using CryptoSideChannel
using Test, StaticArrays
using Distributions


function test_hamming_weight()
    test_key = (hex2bytes("41112233445566778899aabbccddeeff"))
    sample_function(x) = CPA.sample_power_trace(test_key, x, Base.count_ones)
    recovered_key = CPA.CPA_AES_analyze(sample_function, Base.count_ones; N = 2^10)

    @test test_key == recovered_key
end

function test_lsb()
    test_key = (hex2bytes("63f5f4aa80c2c61ae31e8ab9df24ebd4"))
    sample_function(x) = CPA.sample_power_trace(test_key, x, x -> (x) & 1)
    recovered_key = CPA.CPA_AES_analyze(sample_function, x -> x & 0x1; N = 2^10)
    @test test_key == recovered_key
end

function test_msb()
    test_key = (hex2bytes("ab7a2656ee8e4cb06b6cb98df814c6f6"))
    sample_function(x) = CPA.sample_power_trace(test_key, x, x -> (x>>>7) & 1)
    recovered_key = CPA.CPA_AES_analyze(sample_function, x -> (x >>> 7) & 1; N = 2^10)
    @test test_key == recovered_key
end

function test_hamming_noise()
    test_key = (hex2bytes("042788e0999ec84cbeb959cffeaaf2e7"))
    d = Distributions.Normal(0, 3)
    sample_function(x) = CPA.sample_power_trace(test_key, x, x -> Base.count_ones(x) + rand(d))

    recovered_key = CPA.CPA_AES_analyze(sample_function, Base.count_ones; N = 2^10)
    @test test_key == recovered_key
end


test_hamming_weight()
test_lsb()
test_msb()
test_hamming_noise()