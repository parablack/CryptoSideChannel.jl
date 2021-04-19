# Logging

## The `GenericLog` datatype

TBD


## Creating your own cipher traces

TBD

```
trace = []

function encrypt_log_trace(pt::MVector{16, UInt8})
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