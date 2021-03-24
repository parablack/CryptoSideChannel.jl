using CSC, Test
using StaticArrays
using CSC.Logging
using CSC.Masking
using CSC.SPECK

u(i) = convert(UInt64, i)
h(i) = Logging.ForgetfulHammingLog(u(i))
m(i) = Masking.BooleanMask(u(i))
mh(i) = Masking.BooleanMask(h(i))
mm(i) = Masking.BooleanMask(m(i))

function test_lifted_en_decryption(key, pt, ct, lift, reduce)
    # Lift values
    pt_lift = map(lift, pt)
    key_lift = map(lift, key)
    ct_lift = map(lift, ct)

    # Encrypt
    ct_rec = CSC.SPECK.SPECK_encrypt(pt_lift, key_lift)
    # Reduce encrypted
    ct_rec = map(reduce, ct_rec)
    # Assert
    @test ct_rec == ct

    # Decrypt
    pt_rec = CSC.SPECK.SPECK_decrypt(ct_lift, key_lift)
    # Reduce decrypted
    pt_rec = map(reduce, pt_rec)
    # Assert
    @test pt_rec == pt
end

const functions =
    (
        (u, identity),
        (h, Logging.extractValue),
        (m, Masking.unmask),
        (mh, Logging.extractValue ∘ Masking.unmask),
        (mm, Masking.unmask ∘ Masking.unmask),
    )

function test_en_decrypt(key, pt, ct)
    for (lift, reduce) = functions
        test_lifted_en_decryption(key, pt, ct, lift, reduce)
    end
end

test_en_decrypt((0x0f0e0d0c0b0a0908, 0x0706050403020100), (0x6c61766975716520, 0x7469206564616d20), (0xa65d985179783265, 0x7860fedf5c570d18))
test_en_decrypt((0x0f0e0d0c0b0a0908, 0x0706050403020100), (0x0,                0xAABBCCDDEEFF1122), (0x484bc86af7818612, 0x56706bd229933d01))
test_en_decrypt((0xAABBCCDDEEFF1122, 0x3344556677889900), (0x6c61766975716520, 0x7469206564616d20), (0xe23099ee1cf1ede8, 0x8235353dc8e38111))
test_en_decrypt((0x0000000000000000, 0x0000000000000000), (0x0000000000000000, 0x0000000000000000), (7375773579082960246, 2346049177382750829))

function perf_test(f)
    for i = 1:1000000
        f((u(i), u(42 * i)), (u(i * 10000 + 31241), (~u(i) - 1238290348239048)))
    end
end
@time perf_test(SPECK_encrypt)
@time perf_test((x, y) -> SPECK_encrypt(x, y; rounds=32))
@time perf_test(SPECK.SPECK_encrypt_T)
@time perf_test(SPECK.SPECK_encrypt32)