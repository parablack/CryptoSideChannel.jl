using Statistics
using Distributions
using CryptoSideChannel.TemplateAttacks

include("ParseData.jl")


nr_blocks = metadata.nr_trials ÷ metadata.nr_groups

profile_range = 1:metadata.nr_groups * (nr_blocks ÷ 2^3)
attack_range = metadata.nr_groups * (nr_blocks ÷ 2^3) : metadata.nr_groups * (nr_blocks ÷ 2^2)

@views profile_X = X[:,profile_range]
@views profile_B = B[2,profile_range]

toAttack = 7
@views attack_B = B[2,attack_range]
@views attack_X = X[:,attack_range]

attack_vectors_idx = findall(x -> x == toAttack, attack_B)
attack_vectors = attack_X[:,attack_vectors_idx]

result = template_core_attack(profile_X, profile_B, attack_vectors)
println(result[1:20])
