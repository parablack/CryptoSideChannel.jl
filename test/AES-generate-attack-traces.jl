using CryptoSideChannel
using Test, StaticArrays
using Distributions

SECRET_KEY = "426f9faa05e9a343bf67bdc9e3a3f5c0" # change for challenge

coll = []

function encrypt_log_trace(pt::MVector{16, UInt8})
    global coll
    coll = []
    clos = () -> coll
    d = Distributions.Normal(0, 2)

    reduce_function = x -> Base.count_ones(x) + rand(d)

    kl = map(x -> Logging.SingleFunctionLog(x, clos, reduce_function), hex2bytes(SECRET_KEY))
    ptl = map(x -> Logging.SingleFunctionLog(x, clos, reduce_function), pt)

    AES.AES_encrypt(ptl, kl)

    return copy(coll)
end

traces = [MVector{16}(rand(UInt8, 16)) for _=1:2^12]

open("/tmp/data.txt", "w") do io
    println(io, "# In each line, one plaintext is encrypted, and the corresponding trace (Hamming weight of all intermediate values) is collected")
    println(io, "# First array in each line: AES input (16 bytes)")
    println(io, "# Second array in each line: Recorded trace")
    for trace = traces
        print(io, trace)
        print(io, ", ")
        println(io, round.(encrypt_log_trace(trace), digits=2))
    end
end

recovered_key = DPA.DPA_AES_analyze(encrypt_log_trace)
