# Creating your own side-channel traces

One of the main features of this project is the ability to create traces of an arbitrary program working with integers. For example, this feature can be used to obtain traces from a custom cryptographic algorithms which then can be analyzed for vulnerabilities.
Furthermore, trace generation can also be used for generating data for student exercises. A possible task idea is to release a set of a few thousand traces with the goal to reconstruct the secret key used.

In this section, we will look at AES as an example on how to create your own side-channel traces using this framework:

## Unmasked traces

To generate unmasked traces, the following must be provided:
- A `trace` collection array. All collected values will be appended to this array.
!!! note
    The `trace`-array must be a global variable.
- The _reduction function_: Whenever a value `x` is processed, the value `reduce_function(x)` is appended to the array. In this example, we choose `reduce_function = x -> Base.count_ones(x) + rand(d)`, which computes the Hamming weight with some noise.

Then, the trace collection code is:
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

Collecting masked traces is a very similar process. The only difference is that the logging datatype of input and key must be encapsulated in a masking datatype:

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