using CSC, Test, StaticArrays
using CSC.Logging

function test_en_decrypt_uint8(pt, ct, k)
    @test CSC.AES.AES_encrypt_hex(pt, k) == ct
    @test CSC.AES.AES_decrypt_hex(ct, k) == pt
end

function test_en_decrypt_log(pt, ct, k)
    kl = map(Logging.ForgetfulHammingLog, hex2bytes(k))
    ptl = map(Logging.ForgetfulHammingLog, MVector{16}(hex2bytes(pt)))
    ctl = map(Logging.ForgetfulHammingLog, MVector{16}(hex2bytes(ct)))

    @test CSC.AES.AES_encrypt(ptl, kl) == ctl
    @test CSC.AES.AES_decrypt(ctl, kl) == ptl
end

function test_en_decrypt(pt, ct, k)
    test_en_decrypt_uint8(pt, ct, k)
    test_en_decrypt_log(pt, ct, k)
end


# AES-128
test_en_decrypt("00112233445566778899aabbccddeeff", "69c4e0d86a7b0430d8cdb78070b4c55a", "000102030405060708090a0b0c0d0e0f")
test_en_decrypt("6bc1bee22e409f96e93d7e117393172a", "3ad77bb40d7a3660a89ecaf32466ef97", "2b7e151628aed2a6abf7158809cf4f3c")
test_en_decrypt("ae2d8a571e03ac9c9eb76fac45af8e51", "f5d3d58503b9699de785895a96fdbaaf", "2b7e151628aed2a6abf7158809cf4f3c")
test_en_decrypt("30c81c46a35ce411e5fbc1191a0a52ef", "43b1cd7f598ece23881b00e3ed030688", "2b7e151628aed2a6abf7158809cf4f3c")

# AES-192
test_en_decrypt("fffff800000000000000000000000000", "01b0f476d484f43f1aeb6efa9361a8ac", "000000000000000000000000000000000000000000000000")
test_en_decrypt("6bc1bee22e409f96e93d7e117393172a", "bd334f1d6e45f25ff712a214571fa5cc", "8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b")
test_en_decrypt("ae2d8a571e03ac9c9eb76fac45af8e51", "974104846d0ad3ad7734ecb3ecee4eef", "8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b")
test_en_decrypt("30c81c46a35ce411e5fbc1191a0a52ef", "ef7afd2270e2e60adce0ba2face6444e", "8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b")

# AES-256
test_en_decrypt("00112233445566778899aabbccddeeff", "8ea2b7ca516745bfeafc49904b496089", "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f")
test_en_decrypt("6bc1bee22e409f96e93d7e117393172a", "f3eed1bdb5d2a03c064b5a7e3db181f8", "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4")
test_en_decrypt("ae2d8a571e03ac9c9eb76fac45af8e51", "591ccb10d410ed26dc5ba74a31362870", "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4")
test_en_decrypt("30c81c46a35ce411e5fbc1191a0a52ef", "b6ed21b99ca6f4f9f153e7b1beafed1d", "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4")

