# Creating your own side-channel traces


TODO text!

One of the main features of this project is the ability to create traces of your own cryptographic algorithms.

We will look at AES as an example on how to create your own side-channel traces using this framework:

## Unmasked traces

```
trace = []

function encrypt_collect_trace(pt::MVector{16, UInt8})
    global trace
    trace = []
    clos = () -> trace
    d = Distributions.Normal(0, 2)

    reduce_function = x -> Base.count_ones(x) + rand(d)

    kl = map(x -> Logging.SingleFunctionLog(x, clos, reduce_function), hex2bytes(SECRET_KEY))
    ptl = map(x -> Logging.SingleFunctionLog(x, clos, reduce_function), pt)

    AES.AES_encrypt(ptl, kl)

    return copy(trace)
end
```

## Masked traces

```
coll = []

function encrypt_collect_masked_trace(pt::MVector{16, UInt8})
    global coll
    global key
    coll = []
    clos = () -> coll

    reduce_function = x -> Base.count_ones(x)

    kl = map(x -> Masking.BooleanMask(Logging.SingleFunctionLog(x, clos, reduce_function)), key)
    ptl = map(x -> Masking.BooleanMask(Logging.SingleFunctionLog(x, clos, reduce_function)), pt)

    output = (Logging.extractValue ∘ Masking.unmask).(AES.AES_encrypt(ptl, kl))

    return (output, copy(coll))
end
```