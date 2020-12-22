import Base.:+

module CSC

    include("types/HammingWeightLog.jl")

    include("cipher/AES.jl")
    include("cipher/SPECK.jl")

    export AES
    export SPECK
    export HammingWeightLog

end # module