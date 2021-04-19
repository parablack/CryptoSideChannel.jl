"""
This module implements the [SPECK cipher](https://csrc.nist.gov/csrc/media/events/lightweight-cryptography-workshop-2015/documents/papers/session1-shors-paper.pdf).

More documentation can be found in the chapter [SPECK](@ref).
"""
module SPECK

using StaticArrays

function R(x, y, k)
        x = Base.bitrotate(x, -8)
        x += y

        x &= typemax(UInt64)
        x ⊻= k
        x &= typemax(UInt64)
        y = Base.bitrotate(y, 3)
        y ⊻= x
        y &= typemax(UInt64)
        (x, y)
end

function RR(x, y, k)
    y ⊻= x
    y &= typemax(UInt64)
    y = Base.bitrotate(y, -3)
    x ⊻= k
    x &= typemax(UInt64)
    x -= y
    x &= typemax(UInt64)
    x = Base.bitrotate(x, 8)
    (x, y)
end

"""
    SPECK_key_expand(key::Tuple{T, T}, rounds)::Vector{T} where T

Expand the key according to the SPECK key schedule. The result is a vector of length `rounds`, containing each round key.
The first round key is the second component of `key`.
    """
function SPECK_key_expand(key::Tuple{T, T}, rounds)::Vector{T} where T
    key_schedule = Vector{T}(undef, rounds)
    for i = 1 : rounds
        key_schedule[i] = key[2]
        key = R(key..., i - 1)
    end
    key_schedule
end

"""
    SPECK_encrypt(plaintext::Tuple{T, T}, key::Tuple{T, T}; rounds = 32)::Tuple{T,T} where T

Encrypt `plaintext` using `key` with SPECK.

# Arguments
- `plaintext` is 128-bit data, split into two shares of type `T`. Each share should contain 64 bits of the plaintext. `T` can be either `UInt64` or a similar [custom integer](@ref integer_types) type.
- `key` is the 128-bit key, split into two shares of type `T`. Each share should contain 64 bits of the plaintext. `T` can be either `UInt64` or a similar [custom integer](@ref integer_types) type.
- `rounds` is the number of rounds to execute. Defaults to `32`, since this is the number of rounds mentioned in the original specification of SPECK.

# Returns
A `Tuple{T,T}` containing the 128-bit encrypted data in two shares of 64 bit.

!!! note
    T can be a custom integer type, but note that `T` *must* behave like `UInt64`. This includes truncating overflows in additions at 64 bit.

# Example
The example is a SPECK128 test vector from [the original SPECK paper](https://eprint.iacr.org/2013/404.pdf)
```julia-repl
julia> key = (0x0f0e0d0c0b0a0908, 0x0706050403020100)
julia> plaintext = (0x6c61766975716520, 0x7469206564616d20)
julia> SPECK.SPECK_encrypt(plaintext, key)
(0xa65d985179783265, 0x7860fedf5c570d18)
```
    """
function SPECK_encrypt(pt::Tuple{T, T}, key::Tuple{T, T}; rounds = 32)::Tuple{T,T} where T

    key_schedule = SPECK_key_expand(key, rounds)

    for i::UInt64 = 1:rounds
        pt = R(pt..., key_schedule[i])
    end

    pt
end

"""
    SPECK_decrypt(ciphertext::Tuple{T, T}, key::Tuple{T, T}; rounds = 32)::Tuple{T,T} where T

Decrypt `ciphertext` using `key` with SPECK.

# Arguments
- `ciphertext` is 128-bit data, split into two shares of type `T`. Each share should contain 64 bits of the plaintext. `T` can be either `UInt64` or a similar [custom integer](@ref integer_types) type.
- `key` is the 128-bit key, split into two shares of type `T`. Each share should contain 64 bits of the plaintext. `T` can be either `UInt64` or a similar [custom integer](@ref integer_types) type.
- `rounds` is the number of rounds to execute. Defaults to `32`, since this is the number of rounds mentioned in the original specification of SPECK.

# Returns
A `Tuple{T,T}` containing the 128-bit encrypted data in two shares of 64 bit.

!!! note
    T can be a custom integer type, but note that `T` *must* behave like `UInt64`. This includes truncating overflows in additions at 64 bit.

# Example
The example is a SPECK128 test vector from [the original SPECK paper](https://eprint.iacr.org/2013/404.pdf)
```julia-repl
julia> key = (0x0f0e0d0c0b0a0908, 0x0706050403020100)
julia> plaintext = (0x6c61766975716520, 0x7469206564616d20)
julia> SPECK.SPECK_decrypt(ciphertext, key)
(0x6c61766975716520, 0x7469206564616d20)
```
    """
function SPECK_decrypt(ct::Tuple{T, T}, key::Tuple{T, T}; rounds = 32)::Tuple{T,T} where T

    key_schedule = SPECK_key_expand(key, rounds)

    for i::UInt64 = rounds:-1:1
        ct = RR(ct..., key_schedule[i])
    end

    ct
end

function SPECK_key_expand_T(key::Tuple{T, T}, ::Val{rounds})::SVector{rounds, T} where {T, rounds}
    key_schedule = Vector{T}(undef, rounds)
    for i = 1 : rounds
        key_schedule[i] = key[2]
        key = R(key..., i - 1)
    end
    key_schedule
end

SPECK_encrypt_T(pt::Tuple{T, T}, key::Tuple{T, T}, rounds = 32) where T = SPECK_encrypt_T(pt, key, Val(rounds))

function SPECK_encrypt_T(pt::Tuple{T, T}, key::Tuple{T, T}, ::Val{rounds})::Tuple{T,T} where {T, rounds}

    key_schedule = SPECK_key_expand(key, rounds)

    for i::UInt64 = 1:rounds
        pt = R(pt..., key_schedule[i])
    end

    pt
end
export SPECK_encrypt
export SPECK_decrypt

end