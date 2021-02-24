using CSC, Test, StaticArrays
using CSC.Logging

SECRET_KEY = "00000000000000000000000000000000" # change for challenge

coll = []

function encrypt_log_trace(pt::MVector{16, UInt8})
    global coll
    coll = []
    clos = () -> coll
    kl = map(x -> Logging.HammingWeightLog(x, clos), hex2bytes(SECRET_KEY))
    ptl = map(x -> Logging.HammingWeightLog(x, clos), pt)

    CSC.AES.AES_encrypt(ptl, kl)

    return copy(coll)
end

traces = [MVector{16}(rand(UInt8, 16)) for _=1:2^14]

open("/tmp/data.txt", "w") do io
    println(io, "# In each line, one plaintext is encrypted, and the corresponding trace (Hamming weight of all intermediate values) is collected")
    println(io, "# First array in each line: AES input (16 bytes)")
    println(io, "# Second array in each line: Recorded trace")
    for trace = traces
        print(io, trace)
        print(io, ", ")
        println(io, encrypt_log_trace(trace))
    end
end
