using Jlsca
using Jlsca.Sca
using Jlsca.Trs
using StaticArrays
using Printf
using Distributions
using CSC

mkpath("traces")
key = hex2bytes("426f9faa05e9a343bf67bdc9e3a3f5c0")
nrOfTraces  = 1000

filename = @sprintf("traces/csc_aes_masked_%s.trs", bytes2hex(key))
touch(filename)
rm(filename)

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

trs = InspectorTrace(filename, 32, Float32, 24192)

for i = eachindex(inputs)
    input = inputs[i]
    output, trace = encrypt_log_trace(input)
    output = Vector{UInt8}(output)
    trace = Vector{Float32}(trace)
    input = Vector{UInt8}(input)
    trs[i] = ([input;output], trace)
end




attack = AesSboxAttack()
attack.mode = CIPHER
attack.keyLength = KL128
attack.direction = FORWARD
# then an analysis
analysis = Sca.CPA()
analysis.leakages = [HW()] # [Bit(7)]
# combine the two in a DpaAttack. The attack field is now also accessible
# through params.attack, same for params.analysis.
params = DpaAttack(attack,analysis)
params.knownKey = key

sca(trs, params, 1, nrOfTraces)
0