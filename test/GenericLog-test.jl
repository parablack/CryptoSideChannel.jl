using Test, StaticArrays, Random, CryptoSideChannel.Logging

trace = []

function test(ai, bi, op, type, reduce)
    global trace = []
    closure = () -> trace
    #println(typeof(closure))
    @assert (isbitstype(typeof(closure)))
    a = type(ai, () -> trace)
    b = type(bi, () -> trace)
    c = op(a, b)
    expected = op(ai, bi)
    @test Logging.extractValue(c) == expected
    red = reduce(expected)
    @test trace == [red]
end

for i = [0,1,2,3,4,13,255,1337,2^31-1, 2^32, -1, -2, -10, -100, -1337, -2^32]
    for j = [0,1,2,3,4,13,255,1337,2^31-1, 2^32, -1, -2, -10, -100, -1337, -2^32]
        for op = [+, -, *, >>>]
            test(i, j, op, (x, y) -> Logging.FullLog(x, y), identity)

            test(i, j, op, Logging.HammingWeightLog, (Base.count_ones))
            test(i, j, op, (x, y) -> Logging.SingleBitLog(x, y, 0), x -> x & 1)
            test(i, j, op, (x, y) -> Logging.SingleBitLog(x, y, 4), x -> (x>>>4) & 1)

            test(i, j, op, (x, y) -> Logging.SingleFunctionLog(x, y, x->x+2), x -> x + 2)
            test(i, j, op, (x, y) -> Logging.SingleFunctionLog(x, y, x->2*x), x -> 2*x)

         end
    end
end

mask = Logging.randomBitMask(10, 256)

for i = [0,1,2,3,4,13,128,129,255]
    for j = [0,1,2,3,4,13,128,129,255]
        for op = [+, -, *, >>>]
            test(convert(UInt8,i), convert(UInt8,j), op, (x, y) -> Logging.SingleFunctionLog(x, y, x -> mask[x+1]), x -> mask[x+1])
    #        test(convert(UInt8,i), convert(UInt8,j), op, (x, y) -> Logging.ByteMaskLog(x, y, mask), x -> mask[x+1])
        end
    end
end