# Ciphers

## AES
```@meta
CurrentModule = CryptoSideChannel.AES
```


### Encryption and Decryption

The following two methods provide a basic interface for encrypting and decrypting. Both methods are parametrised over the underlying type for the computations.

For simply using AES, one would instantiate `T` as `UInt8`. For more advanced settings that log traces or use masking, refer to the respective chapters.

```@docs
AES_encrypt
AES_decrypt
```

This module also exports methods to en-/decrypt data given as a hexadecimal string:

```@docs
AES_encrypt_hex
AES_decrypt_hex
```

### AES Internal Functions

```@docs
AES.key_expand
AES.inv_key_expand
```

If multiple encryptions are performed with the same key, it is efficient to only compute the key schedule once. The key schedule can be computed with `key_expand` manually. Afterwards, the following two functions can be used for en-/decrypting data with AES with the already computed schedule:
```@docs
AES.AES_encrypt_expanded
AES.AES_decrypt_expanded
```

## SPECK
```@meta
CurrentModule = CryptoSideChannel.SPECK
```

### Encryption and Decryption
```@docs
SPECK.SPECK_encrypt
SPECK.SPECK_decrypt
```


### Internal Functions
```@docs
SPECK.SPECK_key_expand
SPECK.SPECK_encrypt_expanded
SPECK.SPECK_decrypt_expanded
```
