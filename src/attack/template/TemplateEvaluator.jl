"""
The `Templates` struct stores a pooled noise covariance matrix, as well as mean vectors for all integers that are possibly loaded.

If the integer `x` is processed, a random vector from `distribution` is drawn. Then, `values[x]` is added to this random vector.
"""
struct Templates
    distribution::MvNormal
    values::SVector
end


"""
    single_load_instruction(value)

Simulate a single load instruction of `value`.
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
    sample_function(templates::Templates, fun, value)

Sample the provided function `fun` on input `value`.

## Arguments
- `templates` defines the underlying emissions that should be simulated (i.e. mean and covariance matrices for values).
- `fun` must be a function taking a single integer. This function should describe the operation that is targeted. For example, `fun` could be `single_load_instruction` or `multi_load_instructions`.
- `value` should be an integer, or an array of integers that `fun` is executed on.

## Returns
The leakage vector that the execution of `fun` on `value` would produce, assuming that the emissions are defined by `templates`.
"""
function sample_function(template::Templates, fun, value)
    global __rng
    global __values
    global __coll
    __values = template.values
    __coll = []
    __rng = template.distribution

    noise_closure = (x) -> __rng
    template_for_value = (x) -> __values[x+1]

    @assert isbits(noise_closure)
    @assert isbits(template_for_value)

    log_value = map(x -> Logging.StochasticLog(x, () -> __coll, template_for_value, noise_closure), value)
    fun(log_value)

    vcat(__coll...)
    #__coll
end

"""
    generate_attack_vectors(templates::Templates, secret; fun = single_load_instruction, N = 2^10)

Sample `N` attack vectors of the function `fun`.

## Arguments
- `templates` stores the noise distribution of our side-channel.
- `secret` is the secret value that is loaded for our attack. For example, this could be a single key byte.
- `fun` is the function that processes the secret value. This defaults to a single load instruction. This function must take a single integer.
- `N` is the number of attack traces to produce.

## Returns
A list of side-channel attack vectors that record the operation of `fun(secret)`.
The function `fun` must have the type signature `Int -> Any`. `fun` will be executed on input `secret`, which should be an integer or an vector of integers.

The attack vectors are sampled by using the [`sample_function`](@ref).
"""
function generate_attack_vectors(template::Templates, secret; fun = single_load_instruction, N = 2^10)
    @assert N >= 1
    fvector = sample_function(template, fun, secret)
    attack_vectors = zeros(Float64, (length(fvector), N))
    for i = 1:N
        attack_vectors[:,i] = sample_function(template, fun, secret)
    end
    attack_vectors
end
