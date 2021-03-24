using CSC.CPA
using CSC.AES
using StaticArrays



# Northeastern University TeSCASE dataset (https://chest.coe.neu.edu/)
# https://chest.coe.neu.edu/?current_page=POWER_TRACE_LINK&software=ptunmasked


function parse_input_file(fname, number_of_traces)
    inputs = []
    io = open(fname);
    ct = 0
    while (ln = readline(io)) != "" && (ct < number_of_traces)
        input = split(ln)
        parsed_input_vector = []
        for i = input
            num = parse(Int, i)
            @assert 0 <= num <= 255
            push!(parsed_input_vector, convert(UInt8, num))
        end
        # Input vector should consist of 16 bytes
        @assert length(parsed_input_vector) == 16
        push!(inputs, parsed_input_vector)
        ct += 1
    end
    return inputs
end


function parse_trace_file(fname, number_of_traces)
    io = open(fname);
    traces = zeros(UInt16, 3125, number_of_traces)
    ct = 1
    while (ln = readline(io)) != "" && (ct <= number_of_traces)
        input = split(ln)
        parsed_trace_vector = []
        for i = input
            num = parse(Int, i)
            @assert 0 <= num <= 2^16
            push!(parsed_trace_vector, convert(UInt16, num))
        end
        # Traces are 3125 bytes long
        @assert length(parsed_trace_vector) == 3125
        traces[:,ct] = parsed_trace_vector
        ct += 1
    end
    traces
end


