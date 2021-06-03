"""
This module implements Template attacks on cryptographic side channels.

More information can be found at [Template attacks](@ref)
"""
module TemplateAttacks

using CryptoSideChannel.Logging
using StaticArrays
using Distributions
using Random
using DataStructures
using Statistics

include("template/TemplateEvaluator.jl")
include("template/TemplateGenerator.jl")
include("template/LikelyKey.jl")
include("template/TemplateIntegration.jl")

"""
    template_core_attack(profiled_vectors::AbstractMatrix, inputs::AbstractVector, attack_vectors::AbstractMatrix)

# Arguments
- `inputs`: A vector containing ``N`` entries, where ``N`` is the number of sampled vectors. At position ``x`` shall be the input that was used to generate the ``x``-th vector.
- `profiled_vectors`: A ``M \\times N`` matrix. The column `profiled_vectors[:,x]` should contain the data that was generated on input `x`.
- `attack_vectors`: A ``M \\times K`` matrix, where ``K`` is the number of traces from the attacked device.  Traces are stored in column-major order. All traces must be generated with the same secret input.

# Returns
A vector of tuples (likelyhood, value) for all values in `inputs`, sorted by decreasing likelyhood of the value.
"""
function template_core_attack(profiled_vectors::AbstractMatrix, inputs::AbstractVector, attack_vectors::AbstractMatrix)
    keyGuesses = []
    cov = Statistics.cov(profiled_vectors, dims = 2)

    for value = unique(inputs)
        idx = findall(x -> x == value, profiled_vectors_data)
        mean = vec(Statistics.mean(profiled_vectors[:,idx], dims=2))
        mv_distribution = MvNormal(mean, cov)

        # Sum of logarithms is proportional to the product of probabilites. Some factors are lost. Hence, only a likelihood is returned.
        prob = sum(logpdf(mv_distribution, attack_vectors))

        push!(keyGuesses, (prob, value))
    end
    sort!(keyGuesses, rev=true)
    return keyGuesses
end

export template_core_attack
export single_byte_template_attack
export multi_byte_template_attack
export generate_attack_vectors
export random_uncorrelated_templates
export sample_function
export single_load_instruction
export multi_load_instructions
export LikelyKey
end

