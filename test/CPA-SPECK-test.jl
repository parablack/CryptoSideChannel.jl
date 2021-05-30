using CryptoSideChannel
using CryptoSideChannel.CPA
using Test, StaticArrays
using Distributions

key1 = (0xFEDCBA9876543210, 0x0123456789ABCD12)
key2 = (0x0f0e0d0c0b0a0908, 0x07060504030201f0)
key3 = (0x6c61766975716520, 0x7469206564616d20)

function test_speck_hamming_weight(key)
    d = Distributions.Normal(0, 0.3)

    sample_fun = x -> CPA.sample_SPECK_power_trace(key, x, x -> Base.count_ones(x) + rand(d))
    recovered_key = CPA.CPA_SPECK_analyze(sample_fun, Base.count_ones; N = 2^12)

    @test key == recovered_key
end

for x = [key1, key2, key3]
    test_speck_hamming_weight(x)
end