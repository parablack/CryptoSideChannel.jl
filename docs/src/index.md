# `CryptoSideChannel.jl`: A customizable side-channel modelling and analysis framework in Julia

This library focuses on generic side-channel analysis of various cryptographic algorithms. This implementation uses custom types that behave like integers. However, those types may additionally log their values, or mask the internal representation of their values.
In combination, this allows for easy recording of side-channels for educational and testing purposes.

This project is split into three parts:

## Ciphers
Currently, two ciphers are implemented: The [SPECK cipher](https://eprint.iacr.org/2013/404), and the [AES cipher suite](https://csrc.nist.gov/csrc/media/projects/cryptographic-standards-and-guidelines/documents/aes-development/rijndael-ammended.pdf).

```@docs
CryptoSideChannel.AES
```

```@docs
CryptoSideChannel.SPECK
```

## Custom Types
This package currently provides two classes of additional types that mimic integers.


See the [Integer Types](@ref integer_types) page for a more detailed explanation on how to declare custom integer types.


* The `GenericLog` type allows for recording traces of program executions.
* The `Masked` type internally splits its value into two shares. Thus, the content of a `Masked` integer should never be observable in memory.

```@docs
CryptoSideChannel.Logging
```


```@docs
CryptoSideChannel.Masking
```



## Attacks
Multiple side-channel attacks against the ciphers above have been implemented:
* DPA
* CPA
* Template Attacks

```@docs
CryptoSideChannel.DPA
```

```@docs
CryptoSideChannel.CPA
```

```@docs
CryptoSideChannel.TemplateAttacks
```
