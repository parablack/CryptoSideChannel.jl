# Masking

```@meta
CurrentModule = CryptoSideChannel.Masking
```

```@docs
Masked
```

It may be useful to extract the content of a `Masked` type, for example at the end of a cryptographic calculation.
```@docs
unmask
```


## Masking Types

### [Boolean Masking](@id boolean_masking)
```@docs
BooleanMask
```

### [Arithmetic Masking](@id arithmetic_masking)
```@docs
ArithmeticMask
```

### Conversion
```@docs
arithmeticToBoolean
booleanToArithmetic
```

## [Problems with High-level Masking](@id masking_problems)

TODO.

Purport: Compiler optimisations may kill all guarantees. This is for educational / testing purposes only! Do not compile with this tool and expect everything to be safe...


