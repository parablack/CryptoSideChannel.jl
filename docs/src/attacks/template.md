# Template attacks
```@meta
CurrentModule = CryptoSideChannel.TemplateAttacks
```

## Generating vector distributions

A pooled distribution (consisting of different mean vectors for all values and a common covariance matrix) is stored in the following `Templates` struct:
```@docs
Templates
```

These distributions can be created either manually to model a specific behaviour, or can be drawn randomly for testing purposes. The following two methods generate random distributions:
```@docs
random_diagonal_multivariate_distribution
random_uncorrelated_templates
```


## Sampling vectors

Usually, template attacks only target single instructions. For example, the target of an attack could be a single load instruction executed on a microcontroller. Those small targeted instructions are provided by the following two functions:
```@docs
single_load_instruction
multi_load_instructions
```

Given the functions that should be sampled, template vectors are collected using the following `sample_function`. If multiple attack traces with the same input are required, those can be generated with `generate_attack_vectors`.
```@docs
sample_function
generate_attack_vectors
```

## Attacking
```@docs
template_core_attack
```

