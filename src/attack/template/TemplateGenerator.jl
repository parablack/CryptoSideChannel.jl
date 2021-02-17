"""
    random_diagonal_multivariate_distribution(d::Integer)

Generate a random normal multivariate distribution over `d` dimensions. The mean will be a vector chosen randomly from \$\\[0, 1\\]^d\$.

Note that all random values are uncorrelated. Hence, our covariance matrix is a diagonal matrix.
"""
function random_diagonal_multivariate_distribution(dimensions::Integer)
    # Use static seed for testing
    rng = MersenneTwister(1234);

    # Generate a random mean in [0, 1]^d
    mu = rand(rng, dimensions)
    # Our values are uncorrelated, thus we use a diagonal covariance matrix.
    cov = rand(rng, dimensions)
    distribution = MvNormal(mu, cov)

    distribution
end

random_template_values(noise, num_values) = SVector{num_values}([rand(noise) for _ in 1:num_values])

"""
    random_uncorrelated_template(dimensions::Integer, max_value::Integer)

Generate a random template over `d` dimensions, that supports operations on integers between \$0\$ and `max_value`.
"""
function random_uncorrelated_template(dimensions::Integer, max_value::Integer)
    rng = random_diagonal_multivariate_distribution(dimensions)
    template = random_template_values(rng, max_value)
    Template(rng, template)
end
