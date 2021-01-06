import Base.:+

module CSC
    using StaticArrays

    include("types/GenericLog.jl")

    include("cipher/AES.jl")
    include("cipher/SPECK.jl")


    include("attack/DPA.jl")

    export AES
    export SPECK
    export HammingWeightLog
    export ForgetfulHammingLog
    export DPA


end # module