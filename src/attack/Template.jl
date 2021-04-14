
module TemplateAttacks

using CSC.Logging, StaticArrays
using Distributions
using Random
using DataStructures
using Statistics

include("template/TemplateEvaluator.jl")
include("template/TemplateGenerator.jl")
include("template/LikelyKey.jl")
include("template/TemplateIntegration.jl")

"""
    template_core_attack(profiled_vectors::AbstractMatrix, profiled_vectors_data::AbstractVector, attack_vectors::AbstractMatrix)



# Arguments
profiled_vectors: A `number_points_per_trace * num_traces` matrix. In column x are the raw trace points.
profiled_vectors_data: A vector of size `num_traces`. At position x is the input on which the x-th trace was generated.
attack_vectors: A `number_points_per_trace * num_attack_traces` matrix. Columns are interpreted as traces. All traces must come from the same secret input

# Returns
A vector of tuples (likelyhood, value) of the key byte.
"""
function template_core_attack(profiled_vectors::AbstractMatrix, profiled_vectors_data::AbstractVector, attack_vectors::AbstractMatrix)
    keyGuesses = []
    cov = Statistics.cov(profiled_vectors, dims = 2)

    for value = 0:255
        idx = findall(x -> x == value, profiled_vectors_data)
        mean = vec(Statistics.mean(profiled_vectors[:,idx], dims=2))
        #display(value)
        mv_distribution = MvNormal(mean, cov)
        #display(mv_distribution)
        #display(logpdf(mv_distribution, attack_vectors))
        # Sum of logarithms is proportional to the product of probabilites. Some factors are lost. Hence, only a likelyhood is returned.
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
export random_uncorrelated_template
export single_load_instruction
export multi_load_instructions
export LikelyKey
end

