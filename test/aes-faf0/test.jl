using Test
using CryptoSideChannel

include("aes-code.jl")

coll = []

function test_en_decrypt(pt, ct, k)
    global coll
    clos = () -> coll
    pt = hex2bytes(pt)
    ct = hex2bytes(ct)
    k  = hex2bytes(k)

    pt = map(x -> Logging.HammingWeightLog(x, clos), pt)
    k  = map(x -> Logging.HammingWeightLog(x, clos), k)

    res = AESEncrypt(pt, k)
    res = map(Logging.extractValue, res)

    @test res == ct
    @test length(coll) != 0
end


test_en_decrypt("00112233445566778899aabbccddeeff", "69c4e0d86a7b0430d8cdb78070b4c55a", "000102030405060708090a0b0c0d0e0f")
test_en_decrypt("00112233445566778899aabbccddeeff", "69c4e0d86a7b0430d8cdb78070b4c55a", "000102030405060708090a0b0c0d0e0f")
test_en_decrypt("6bc1bee22e409f96e93d7e117393172a", "3ad77bb40d7a3660a89ecaf32466ef97", "2b7e151628aed2a6abf7158809cf4f3c")
test_en_decrypt("ae2d8a571e03ac9c9eb76fac45af8e51", "f5d3d58503b9699de785895a96fdbaaf", "2b7e151628aed2a6abf7158809cf4f3c")