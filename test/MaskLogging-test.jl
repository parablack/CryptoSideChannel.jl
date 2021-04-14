using Test, StaticArrays, Random, CSC


al(x) = Masking.ArithmeticMask(Logging.ForgetfulHammingLog(x))
u = (Logging.extractValue ∘ Masking.unmask)


TEST_TUPLE = (2, 4, 6)
TEST_ARRAY = [123, 0x125, 1337, 42, 45, 45, 45, 45, 45]

for index = 1:length(TEST_TUPLE)
    masked_index = al(index)
    @test u(TEST_TUPLE[masked_index]) == TEST_TUPLE[index]
end

for index = 1:length(TEST_ARRAY)
    masked_index = al(index)
    @test u(TEST_ARRAY[masked_index]) == TEST_ARRAY[index]
end

tval = al(123123)
tval2 = al(0x42)
t = convert(typeof(tval), tval2)

@test Logging.extractValue(Masking.unmask(t)) == 0x42