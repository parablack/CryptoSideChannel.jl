import Base.:+

module CSC

    include("cipher/AES.jl")
    include("cipher/SPECK.jl")
    include("types/HammingWeightLog.jl")



    println(CSC.SPECK.encrypt([HammingWeightLog(0),HammingWeightLog(0)], [HammingWeightLog(0),HammingWeightLog(0)], 32))
    export AES
    export add
    export SPECK

end # module