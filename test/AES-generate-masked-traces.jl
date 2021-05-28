using CryptoSideChannel, Test, StaticArrays
using Distributions
using CryptoSideChannel.Logging
using CryptoSideChannel.Masking


SECRET_KEY = hex2bytes("426f9faa05e9a343bf67bdc9e3a3f5c0")
nrOfTraces  = 1

coll = []

function encrypt_log_trace(plaintext::MVector{16, UInt8})
    global coll
    coll = []
    clos = () -> coll

    reduction_function = x -> Base.count_ones(x)

    key_log = GenericLog.(SECRET_KEY, clos, reduction_function)
    pt_log  = GenericLog.(plaintext, clos, reduction_function)

    key_masked = BooleanMask.(key_log)
    pt_masked = BooleanMask.(pt_log)

    output = (Logging.extractValue ∘ Masking.unmask).(AES.AES_encrypt(pt_masked, key_masked))

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
