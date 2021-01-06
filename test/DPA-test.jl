using CSC.DPA, Test, StaticArrays

test_key = (hex2bytes("41112233445566778899aabbccddeeff"))
sample_function(x) = DPA.sample_power_trace(test_key, x)
recovered_key = DPA.DPA_AES_analyze(sample_function)

@test test_key == recovered_key