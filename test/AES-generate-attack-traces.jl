using CryptoSideChannel
using Test, StaticArrays
using Distributions
using CryptoSideChannel.Logging

SECRET_KEY = hex2bytes("426f9faa05e9a343bf67bdc9e3a3f5c0") # change for challenge

trace = Float64[]

function encrypt_log_trace(plaintext)
    global trace
    trace = Float64[]
    clos = () -> trace

    d = Distributions.Normal(0, 3)
    reduction_function = x -> Base.count_ones(x) + rand(d)

    key_log = GenericLog.(SECRET_KEY, clos, reduction_function)
    pt_log  = GenericLog.(plaintext, clos, reduction_function)

    AES.AES_encrypt(pt_log, key_log)

    return copy(trace)
end

traces = [MVector{16}(rand(UInt8, 16)) for _=1:2^12]

open("/tmp/data.txt", "w") do io
    println(io, "# In each line, one plaintext is encrypted, and the corresponding trace (Hamming weight of all intermediate values) is traceected")
    println(io, "# First array in each line: AES input (16 bytes)")
    println(io, "# Second array in each line: Recorded trace")
    for trace = traces
        print(io, trace)
        print(io, ", ")
        println(io, round.(encrypt_log_trace(trace), digits=2))
    end
end

println("Done")

recovered_key = DPA.DPA_AES_analyze(encrypt_log_trace)
