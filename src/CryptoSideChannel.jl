import Base.:+

"""
The `CryptoSideChannel` library focuses on generic side-channel analysis of cryptographic algorithms. The implementation uses custom types that behave like integers. However, those types may additionally log their values, or mask the internal representation of their values.
In combination, this allows for easy recording of masked-and unmasked side-channels for educational and testing purposes. See the chapter on [Custom Types](@ref) for more information about this part.

Furthermore, this library implements two ciphers, namely the Advanced Encryption Standard (AES) and SPECK. More information can be found in the [Ciphers](@ref home_ciphers) chapter of the documentation.

Lastly, this project implements several attacks against the recorded traces. See the chapter on [Attacks](@ref) for more details.
"""
module CryptoSideChannel

include("types/GenericLog.jl")
include("types/Masking.jl")

include("cipher/AES.jl")
include("cipher/SPECK.jl")


include("attack/DPA.jl")
include("attack/CPA.jl")
include("attack/Template.jl")

export AES
export SPECK
export Logging
export Masking
export DPA
export CPA
export TemplateAttacks

end # module