## `CryptoSideChannel.jl`: A customizable side-channel modelling and analysis framework in Julia

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://parablack.github.io/CryptoSideChannel.jl/dev/)
[![Build Status](https://travis-ci.com/parablack/CryptoSideChannel.jl.svg?branch=master)](https://travis-ci.com/parablack/CryptoSideChannel.jl)

This library focuses on generic side-channel analysis of cryptographic algorithms. The implementation uses custom types that behave like integers. However, those types may additionally log their values, or mask the internal representation of their values. In combination, this allows for easy recording of masked-and unmasked side-channels for educational and testing purposes.
Furthermore, this library implements two ciphers, namely the Advanced Encryption Standard (AES) and SPECK. Lastly, this project implements several attacks against the recorded traces.

More details about the implementation can be found in [the documentation](https://parablack.github.io/CryptoSideChannel.jl/dev/).

### Installation
This project is bundled as a Julia package. Unfortunately, the `Jlsca` dependency is currently unregistered. Thus, it has to be added manually before installing this package.

In the Julia REPL, this project can be installed by typing the following commands:
```julia-repl
julia> using Pkg
julia> Pkg.add(PackageSpec(url="https://github.com/Riscure/Jlsca"))
julia> Pkg.add(PackageSpec(url="https://github.com/parablack/CryptoSideChannel.jl"))
```

Alternatively, this package can be directly installed from the `Pkg` command line interface:
```julia-repl
julia> ]
(@v1.6) pkg> add https://github.com/Riscure/Jlsca
(@v1.6) pkg> add https://github.com/parablack/CryptoSideChannel.jl
```