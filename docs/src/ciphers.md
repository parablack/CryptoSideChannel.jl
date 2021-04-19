# Ciphers

## AES
```@meta
CurrentModule = CryptoSideChannel.AES
```


### Encryption and Decryption

The following two methods provide a basic interface for encrypting and decrypting. Both methods are parametrised over the underlying type for the computations.

For simply using AES, one would instantiate `T` as `UInt8`. For more advanced settings that log traces or use masking, refer to the respective chapters.  TODO references

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
```