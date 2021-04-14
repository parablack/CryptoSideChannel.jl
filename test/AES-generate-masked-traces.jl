using CSC, Test, StaticArrays
using CSC.Logging
using Distributions


key = hex2bytes("426f9faa05e9a343bf67bdc9e3a3f5c0")
nrOfTraces  = 1

coll = []

function encrypt_log_trace(pt::MVector{16, UInt8})
    global coll
    global key
    coll = []
    clos = () -> coll

    reduce_function = x -> Base.count_ones(x)

    kl = map(x -> Masking.BooleanMask(Logging.SingleFunctionLog(x, clos, reduce_function)), key)
    ptl = map(x -> Masking.BooleanMask(Logging.SingleFunctionLog(x, clos, reduce_function)), pt)

    output = (Logging.extractValue ∘ Masking.unmask).(CSC.AES.AES_encrypt(ptl, kl))

    return (output, copy(coll))
end

inputs = [MVector{16}(rand(UInt8, 16)) for _=1:nrOfTraces]

for i = eachindex(inputs)
    input = inputs[i]
    output, trace = encrypt_log_trace(input)
    output = Vector{UInt8}(output)
    trace = Vector{Float32}(trace)
    println(length(trace))
    input = Vector{UInt8}(input)
end
