using Plots
include("ParseData.jl")

N = 1
traces = parse_trace_file("/run/media/simon/D-Platte/Uni/aes/001_trace_int.txt", 1)

plottrace = traces[:, 1]


plot(eachindex(plottrace), plottrace, labels="", xlabel="Time", ylabel="Power consumption")

savefig("aes_realworld_onetrace.png")