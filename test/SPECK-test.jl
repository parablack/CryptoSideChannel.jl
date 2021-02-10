using CSC, Test
using StaticArrays
using CSC.Logging
using CSC.Masking

u(i) = convert(UInt64, i)
h(i) = Logging.ForgetfulHammingLog(u(i))
m(i) = Masking.BooleanMask(u(i))
mh(i) = Masking.BooleanMask(h(i))
mm(i) = Masking.BooleanMask(m(i))


function test_encrypt(key, pt, ct)
    result = CSC.SPECK.encrypt(
        SVector(u(pt[1]),u(pt[2])),
        SVector(u(key[1]),u(key[2])),
        32
        )
    @test result == ct

    # Test with Forgetful Log
    result = CSC.SPECK.encrypt(
        SVector(h(pt[1]),h(pt[2])),
        SVector(h(key[1]),h(key[2])),
        32
        )
    @test map(x -> Logging.extractValue(x), result) == ct

    # Test with Masked values
    result = CSC.SPECK.encrypt(
        SVector(m(pt[1]),m(pt[2])),
        SVector(m(key[1]),m(key[2])),
        32
        )
    @test map(Masking.unmask, result) == ct

     # Test with masked logging values
     result = CSC.SPECK.encrypt(
        SVector(mh(pt[1]),mh(pt[2])),
        SVector(mh(key[1]),mh(key[2])),
        32
        )
    @test map(Logging.extractValue ∘ Masking.unmask, result) == ct

    # Test with masked masked values (= higher order masking)
    result = CSC.SPECK.encrypt(
    SVector(mm(pt[1]),mm(pt[2])),
    SVector(mm(key[1]),mm(key[2])),
    32
    )
    @test map(Masking.unmask ∘ Masking.unmask, result) == ct

end

test_encrypt((0x0f0e0d0c0b0a0908, 0x0706050403020100), (0x6c61766975716520, 0x7469206564616d20), (0xa65d985179783265, 0x7860fedf5c570d18))
test_encrypt((0x0f0e0d0c0b0a0908, 0x0706050403020100), (0x0,                0xAABBCCDDEEFF1122), (0x484bc86af7818612, 0x56706bd229933d01))
test_encrypt((0xAABBCCDDEEFF1122, 0x3344556677889900), (0x6c61766975716520, 0x7469206564616d20), (0xe23099ee1cf1ede8, 0x8235353dc8e38111))
test_encrypt((0x0000000000000000, 0x0000000000000000), (0x0000000000000000, 0x0000000000000000), (7375773579082960246, 2346049177382750829))