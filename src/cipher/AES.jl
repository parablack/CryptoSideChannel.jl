"""
This module provides an implementation of the [AES algorithm](https://csrc.nist.gov/csrc/media/projects/cryptographic-standards-and-guidelines/documents/aes-development/rijndael-ammended.pdf).

Further documentation can be found at [AES](@ref).
"""
module AES

using StaticArrays


# The AES SBOX, source: https://github.com/kokke/tiny-AES-c/blob/master/aes.c
const c_sbox = (
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
)

# Inverse of the AES SBOX, source: https://github.com/kokke/tiny-AES-c/blob/master/aes.c
const c_sboxi = (
    0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
    0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
    0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
    0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
    0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
    0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
    0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
    0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
    0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
    0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
    0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
    0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
    0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
    0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
    0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
    0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
)

# AES key schedule round constants, precomputed
# Source: https://en.wikipedia.org/wiki/Rijndael_key_schedule#Rcon
const c_rcon = UInt8[0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36]

# The constant number of columns of a state in AES.
const Nb = 4

# The key size of a key k (type: Array{UInt8, 1}) in 32-bit words.
keysizewords(k) = length(k) ÷ 4

# The number of rounds to perform with respective key
roundsbykey(k) = Dict(4=>10, 6=>12, 8=>14)[keysizewords(k)]

# Apply the sbox directly, or to vectors of types.
sub_bytes(w) = c_sbox[w+1]
sub_bytes(w::AbstractArray) =  map(x -> c_sbox[x+1], w)
inv_sub_bytes(w) = c_sboxi[w+1]
inv_sub_bytes(w::AbstractArray) = map(x -> c_sboxi[x+1], w)
sub_bytes!(w) = map!(sub_bytes, w, w)
inv_sub_bytes!(w) = map!(inv_sub_bytes, w, w)

# Add round key to state, as described in the AES paper
function add_round_key!(state, keys, round)
    key = permutedims(reshape(keys[(4*4) * round + 1 : (4*4) * (round + 1)], 4, 4), [2,1])
    state .⊻= key
end

# Shift rows, as described in the AES paper
function shift_rows!(state)
    for i = 1:4
        state[1:4,i] = state[map(x->1+mod(x+i-1,4),0:3),i]
    end
    state
end

# Inverse shift rows, as described in the AES paper
function inv_shift_rows!(state)
    for i = 1:4
        state[1:4,i] = state[map(x->1+mod(x-i+1,4),0:3),i]
    end
    state
end

rcon(i::Integer) = [c_rcon[i],0x0,0x0,0x0]

"""
    key_expand(k::Vector{T})

Compute the [AES key schedule](https://en.wikipedia.org/wiki/AES_key_schedule)

# Arguments
- `k` is the key for the AES algorithm. It should be a vector of type T, which must be an UInt8-like type.
    The key is required to be a valid key for AES-128, AES-196, or AES-256. Hence, `k` must be either 16, 24, or 32 bytes long.

# Returns
An vector of type T containing the whole key schedule.
"""
function key_expand(k::Vector{T})::Vector{T} where T
    @assert keysizewords(k) == 4 || keysizewords(k) == 6 || keysizewords(k) == 8
    Nk = convert(UInt8, keysizewords(k))
    Nr = convert(UInt8, roundsbykey(k))
    w = Vector{T}(undef, 4 * Nb * (Nr + 1))
    w[1:4*Nk] = copy(k)
    for i::UInt8 = Nk:(Nb * (Nr + 1) - 1)
        w1 = w[((i-1) * 4 + 1) : (i * 4)]
        if i % Nk == 0
            value = xor.(sub_bytes(w1[[2,3,4,1]]), rcon(i ÷ Nk))
        elseif (Nk > 6) && i % Nk == 4
            value = sub_bytes(w1)
        else
            value = w1
        end
        w[(i * 4 + 1) : ((i+1) * 4)] = xor.(w[((i - Nk) * 4 + 1):((i - Nk + 1) * 4)], value)
    end
    w
end

"""
    inv_key_expand(k::Vector{T})

Compute the [AES key schedule](https://en.wikipedia.org/wiki/AES_key_schedule) given only the **last round key**.
This is useful for attacks targeting the last round key, or for computing the decryption key on-the-fly.

!!! warning
    This algorithm is currently only implemented for AES-128.

# Arguments
- `k` is the last round key used in the AES algorithm. It should be a vector of type T, which must be an UInt8-like type.
    The key is required to be a valid round key for AES. Hence, `k` must be exactly 16 bytes long.

# Returns
An vector of type T containing the whole key schedule. Most importantly, the first 16 bytes of this vector are the original AES-128 key.

# Example
```julia-repl
julia> key = hex2bytes("000102030405060708090a0b0c0d0e0f")
julia> last_round_key = AES.key_expand(key)[end-15:end]
julia> recovered_key = AES.inv_key_expand(last_round_key)[1:16]
julia> bytes2hex(recovered_key)
"000102030405060708090a0b0c0d0e0f"
```
"""
function inv_key_expand(k::Vector{T}) where T
    @assert keysizewords(k) == 4
    rounds = 10 # Correct for AES-128
    w = zeros(UInt8, 4 * 4 * (rounds + 1))
    # Insert last round key to array
    w[4 * 4 * (rounds) + 1:4 * 4 * (rounds + 1)] = copy(k)

    # Go through all rounds backwards, always compute the key for the respective round
    # Hence, all round keys are reconstructed backwards
    for round::UInt = rounds - 1:-1:0
        block_start = 4 * 4 * round + 1
        block_end = 4 * 4 * (round + 1)
        next_block_start = block_end + 1
        # Copy key from next block to this block
        w[block_start : block_end] = w[next_block_start : 4 * 4 * (round + 2)]

        # Reconstruct the last 3 words in this block (those are generated using the rule W_i = W_{i-4} ⊻ W_{i - 1})
        for i = 3:-1:1
            word_offset_start = i * 4
            word_offset_end = (i + 1) * 4 - 1
            w[block_start + word_offset_start : block_start + word_offset_end] .⊻=
                w[next_block_start - 4 + word_offset_start : next_block_start - 4 + word_offset_end]
        end

        # Reconstruct the first word in this block
        w[block_start + 0 * 4 : block_start + 1 * 4 - 1] .⊻=
            sub_bytes(w[next_block_start - 1 * 4 : next_block_start + 0 * 4 - 1][[2,3,4,1]])
        w[block_start + 0 * 4 : block_start + 1 * 4 - 1] .⊻= rcon(round + 1)

    end
    return w
end


# Multiply x by 2 in GF(2^8)
multiply(x) = ((x<<0x01) ⊻ (((x>>>0x07) & 0x01) * 0x1b))
# Multiply x by y in GF(2^8)
multiply(x, y) = (((y & 0x01) * x) ⊻
        ((y>>1 & 0x01) * multiply(x)) ⊻
        ((y>>2 & 0x01) * multiply(multiply(x))) ⊻
        ((y>>3 & 0x01) * multiply(multiply(multiply(x)))) ⊻
        ((y>>4 & 0x01) * multiply(multiply(multiply(multiply(x)))))) & 0xFF

# mix_columns step, adapted from https://github.com/kokke/tiny-AES-c/blob/master/aes.c
function mix_columns!(state::Matrix{T}) where T
    for i = 1:4
        t   = state[i,1];
        Tmp = state[i,1] ⊻ state[i,2] ⊻ state[i,3] ⊻ state[i,4] ;
        Tm  = state[i,1] ⊻ state[i,2] ; Tm = multiply(Tm);  state[i,1] ⊻= Tm ⊻ Tmp ;
        Tm  = state[i,2] ⊻ state[i,3] ; Tm = multiply(Tm);  state[i,2] ⊻= Tm ⊻ Tmp ;
        Tm  = state[i,3] ⊻ state[i,4] ; Tm = multiply(Tm);  state[i,3] ⊻= Tm ⊻ Tmp ;
        Tm  = state[i,4] ⊻ t ;          Tm = multiply(Tm);  state[i,4] ⊻= Tm ⊻ Tmp ;
    end
end

function inv_mix_columns!(state::Matrix{T}) where T
    for i = 1:4
        a = state[i,1];
        b = state[i,2];
        c = state[i,3];
        d = state[i,4];

        state[i,1] = multiply(a, 0x0e) ⊻ multiply(b, 0x0b) ⊻ multiply(c, 0x0d) ⊻ multiply(d, 0x09);
        state[i,2] = multiply(a, 0x09) ⊻ multiply(b, 0x0e) ⊻ multiply(c, 0x0b) ⊻ multiply(d, 0x0d);
        state[i,3] = multiply(a, 0x0d) ⊻ multiply(b, 0x09) ⊻ multiply(c, 0x0e) ⊻ multiply(d, 0x0b);
        state[i,4] = multiply(a, 0x0b) ⊻ multiply(b, 0x0d) ⊻ multiply(c, 0x09) ⊻ multiply(d, 0x0e);
    end
end

"""
    AES_encrypt(plaintext::MVector{16,T}, key::Vector{T})::MVector{16,T} where T

Encrypt a block of 16 bytes with AES.

`T` must behave similarly to `UInt8`. For instantiating `T` with logging or protecting types, see the article on [Integer Types](@ref).
    TODO references to the relevant types chapter.

# Arguments
- `plaintext` must be a mutable, statically sized Vector of length 16. It contains the text to encrypt.
- `key` is a vector containing the key used for the encryption. It must be either of length 16, 24, or 32.
    Depending on its length, different variants of AES are dispatched:
    - Length 16: AES-128
    - Length 24: AES-196
    - Length 32: AES-256

# Returns
A `MVector{16,T}` containing the 16-byte long encrypted block.
"""
function AES_encrypt(pt::MVector{16,T}, k::Vector{T})::MVector{16,T} where T
    @assert length(pt) == 16
    key_schedule = key_expand(k)
    state = (permutedims(reshape(pt, 4, 4), [2,1]))
    rounds = roundsbykey(k)
    add_round_key!(state, key_schedule, 0)

    for round = 1:rounds
        sub_bytes!(state)
        shift_rows!(state)
        if round != rounds
            mix_columns!(state)
        end
        add_round_key!(state,key_schedule,round)
    end
    state = reshape(permutedims(state, [2,1]), 16)
    vec(state)
end

"""
    AES_decrypt(ciphertext::MVector{16,T}, key::Vector{T})::MVector{16,T} where T

Decrypt a block of 16 bytes with AES.

`T` must behave similarly to `UInt8`. For instantiating `T` with logging or protecting types, see the article on [Integer Types](@ref).
    TODO references to the relevant types chapter.

# Arguments
- `ciphertext` must be a mutable, statically sized Vector of length 16. It contains the data to decrypt.
- `key` is a vector containing the key used for the decryption. It must be either of length 16, 24, or 32.
    Depending on its length, different variants of AES are dispatched:
    - Length 16: AES-128
    - Length 24: AES-196
    - Length 32: AES-256

# Returns
A `MVector{16,T}` containing the 16-byte long decrypted block.
"""
function AES_decrypt(ct::MVector{16,T}, k::Vector{T})::MVector{16,T} where T
    @assert length(ct) == 16

    key_schedule = key_expand(k)
    state = permutedims(reshape(ct, 4, 4), [2,1])
    rounds = roundsbykey(k)
    add_round_key!(state, key_schedule, rounds)

    for round = rounds-1:-1:0
        inv_shift_rows!(state)
        inv_sub_bytes!(state)
        add_round_key!(state,key_schedule,round)
        if round != 0
            inv_mix_columns!(state)
        end
    end
    state = reshape(permutedims(state, [2,1]), 16)
    vec(state)
end

"""
    AES_encrypt_hex(plaintext::String, key::String)

Interpret `plaintext` and `key` in hexadecimal. Return a string containing the hexadecimal encrypted block.
See [`AES_encrypt`](@ref) for more details.

# Example
```julia-repl
julia> AES_encrypt_hex("00112233445566778899aabbccddeeff", "000102030405060708090a0b0c0d0e0f")
"69c4e0d86a7b0430d8cdb78070b4c55a"
```
"""
function AES_encrypt_hex(plaintext::String, key::String)
    @assert length(plaintext) == 32
    bytes2hex(AES_encrypt(MVector{16}(hex2bytes(plaintext)), hex2bytes(key)))
end

"""
    AES_decrypt_hex(ciphertext::String, key::String)

Interpret `ciphertext` and `key` in hexadecimal. Return a string containing the hexadecimal decrypted block.
See [`AES_decrypt`](@ref) for more details.

# Example
```julia-repl
julia> AES_decrypt_hex("69c4e0d86a7b0430d8cdb78070b4c55a", "000102030405060708090a0b0c0d0e0f")
"00112233445566778899aabbccddeeff"
```
"""
function AES_decrypt_hex(ciphertext::String, key::String)
    @assert length(ciphertext) == 32
    bytes2hex(AES_decrypt(MVector{16}(hex2bytes(ciphertext)), hex2bytes(key)))
end

export AES_encrypt
export AES_decrypt
export AES_encrypt_hex
export AES_decrypt_hex


end