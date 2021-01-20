import Base.:+

module CSC
    using StaticArrays

    include("types/GenericLog.jl")

    include("cipher/AES.jl")
    include("cipher/SPECK.jl")


    include("attack/DPA.jl")
    include("attack/CPA.jl")

    export AES
    export SPECK
    export Logging
    export DPA
    export CPA

end # module