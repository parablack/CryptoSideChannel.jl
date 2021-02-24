"""
The `Template` struct stores a noise distribution, as well as values for integers that are logged.

If the integer `x` is logged, a random vector from `distribution` is drawn. Then, `values[x]` is added to this random vector.
"""
    struct Template
        distribution::MvNormal
        values::SVector
    end


"""
    single_load_instruction(value)

Simulate a single load instruction of `value`
"""
single_load_instruction(value) = value + 0

"""
    multi_load_instructions(a::Vector)

Simulate multiple consecutive load instructions for all values in the vector `a`, in the order of the vector.
"""
function multi_load_instructions(a::Vector)
    foreach(x -> x + 0, a)
end

"""
    sample_function(template::Template, fun, value)

Sample the provided function `fun` on input `value`. `fun` must be of type `Int -> Any`, `value` should be an integer, or an array of integers.

Return the leakage vector that the execution of `fun` on `value` would produce.
All parameters for the leakage vector are defined by `template`.
"""
function sample_function(template::Template, fun, value)
    global __rng
    global __values
    global __coll
    __values = template.values
    __coll = []
    __rng = template.distribution

    noise_closure = () -> __rng
    template_for_value = (x) -> __values[x+1]

    @assert isbits(noise_closure)
    @assert isbits(template_for_value)

    log_value = map(x -> Logging.StochasticLog(x, () -> __coll, template_for_value, noise_closure), value)
    fun(log_value)

    vcat(__coll...)
end

"""
    generate_attack_vectors(template::Template, secret, fun = sample_load, N = 2^10)

Sample `N` attack vectors of the function `fun`. The function `fun` must have the type signature `Int -> Any`. `fun` will be executed on input `secret`, which should be an integer or an vector of integers.

The attack vectors are sampled by using [sample_function](@ref).
"""
function generate_attack_vectors(template::Template, secret; fun = single_load_instruction, N = 2^10)
    @assert N >= 1
    fvector = sample_function(template, fun, secret)
    attack_vectors = zeros(Float64, (length(fvector), N))
    for i = 1:N
        attack_vectors[:,i] = sample_function(template, fun, secret)
    end
    attack_vectors
end
