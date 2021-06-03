using Plots
include("ParseData.jl")

println("Parsing...")

N = 1
traces = parse_trace_file("/home/simon/Documents/Uni/cam/thesis/traces/001_trace_int.txt", 1)

plottrace = traces[:, 1]


plot(eachindex(plottrace), plottrace, labels="", xlabel="Time", ylabel="Power trace")

savefig("aes_realworld_onetrace.png")
println("Done")