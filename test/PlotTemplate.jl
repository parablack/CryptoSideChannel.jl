using CryptoSideChannel
using CryptoSideChannel.TemplateAttacks
using Plots
using StaticArrays
using Distributions

tpl =  TemplateAttacks.random_uncorrelated_templates(2, 8)

tpl = TemplateAttacks.Templates(tpl.distribution, SVector{8}([[1.8056573519004935, -0.4204313914687252], [-1.433907186508715, 2.637960067192525], [-0.915020909099572, -2.354579891391216], [-1.0633531238842877, 0.8041591940821887], [0.5142954878534466, 3.0768711054697717], [-1.4969269482348644, -1.233501328520895], [0.20881142439244056, -1.530249552511473], [0.36441594961704044, -0.17847233653199834]]))

vecs = TemplateAttacks.generate_attack_vectors(tpl, 2; N = 24)

vals = tpl.values
vals_x = map(x -> x[1], vals)
vals_y = map(x -> x[2], vals)

display(tpl)

plt = plot(yrange=(-4,4), xrange=(-4,4))

markercolors = [
    :green  :red    :black :purple
    :orange :yellow :brown :white
]

plt = scatter!(vecs[1,:], vecs[2,:], color=:blue, label="Recorded data points")

for k = eachindex(vals_x)
    scatter!([vals_x[k]], [vals_y[k]], label="Mean for value $k", shape=:star5, color=markercolors[k], markersize=8)
end

#display(plt)
#png(plt, "template_how_are_points_placed.png")

plt = plot(xrange=(0.5, 8.5, 1), yrange=(0, 800), xsteps=1, xlabel="Value", ylabel="Likelihood", ytickfontsize=1)
#for k = eachindex(vals)
for k = 3
    mean_ = vals[k]
    cov = tpl.distribution.Σ
    mv_distribution = MvNormal(mean_, cov)
    #display(mv_distribution)
    #display(logpdf(mv_distribution, attack_vectors))
    # Sum of logarithms is proportional to the product of probabilites. Some factors are lost. Hence, only a likelihood is returned.

    vv = pdf(mv_distribution, vecs)
    display(vv)
    display(mean(vv))

    prob = sum(logpdf(mv_distribution, vecs)) + 800

    bar!([k], [prob], color=markercolors[k], label="", xticks=1:8)
end
#display(plt)
#png(plt, "template_value_likelihood.png")