using Plots
include("ParseData.jl")

N = 1
traces = parse_trace_file("~/Documents/Uni/cam/thesis/traces/001_trace_int.txt", 1)

plottrace = traces[:, 1]


plot(eachindex(plottrace), plottrace, labels="", xlabel="Time", ylabel="Power consumption")

savefig("aes_realworld_onetrace.png")