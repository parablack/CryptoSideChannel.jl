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
We defined our `Masked` datatype as a construct in the high-level Julia language. This poses some problems with respect to compiler optimisations.
Essentially, all masking security guarantees rely on the fact that some intermediate values will never appear in memory. However, the masking approach introduces new, "unneccessary" computation instructions. Depending on compiler optimisations, some of the masking steps may be removed in the final executable.

For example, consider the masked array lookup. Recall that for a table lookup ``Y = T[X]``, with ``X = A_X \oplus M_X`` a table ``T'`` with ``T'[X] = T[X \oplus M_X] \oplus M'_X`` is computed. Later on, the table is only accessed at index ``A_X``. Hence, a compiler may notice that all other fields of the table are never accessed, and may optimize the code in the final program to only compute ``T'[A_X] = T[A_X \oplus M_X] \oplus M'_X``. However, note that for computing the latter, ``A_X \oplus M_X`` appears as an intermediate result. Thus, this may allow conclusions about the unmasked value.

The consequences of this issues is simple: This project is for academic, testing, and educational purposes only. Do not use the `Masked` datatype as a protection in a real-world system. Exploring ways to preserve masking through compiler optimisations in Julia could be done in future work.

## [Defining new methods for `Masked` types](@id extending_masking_funs)
It is possible to extend the provided methods for `Masked` types with custom methods.

The first decision that has to be made is whether the operation should be implemented for arithmetic masking or for boolean masking.
In general, methods requiring arithmetic over ``\mathbb{Z}`` are suitable for arithmetic masking, while methods using bitwise operations often require boolean masking.

Next, the desired operator has to be implemented. For example, we will show how to implement the boolean negation `~`. Since this operator works bitwise, we will immplement the masked version on boolean masking. Recall that we want to invert a value ``X = A_X \oplus M_X``. Here, it is sufficient to simply invert the mask:
```julia
function Base.:(~)(a::Masked{Boolean})::Masked{Boolean}
    Masked{Boolean,typeof(a.val),typeof(a.mask)}(a.val, ~a.mask)
end
```

To complete this definition for all masked datatypes, we need to define the method for arithmetic masking as well. However, now simple conversion can be used to convert from arithmetic to boolean masking:
```julia
Base.:(~)(a::Masked{Arithmetic}) = ~arithmeticToBoolean(a)
```

!!! warning
Be cautious when extending the `Masked` datatype. During any new custom operation the unmasked value should never be computed.