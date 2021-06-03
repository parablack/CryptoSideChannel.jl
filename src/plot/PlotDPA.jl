using StaticArrays
using Plots
using CryptoSideChannel.DPA


test_key = (hex2bytes("42112233445566778899aabbccddeeff"))
sample_function(x) = DPA.sample_power_trace_noise(test_key, x)
tracesO = [MVector{16}(rand(UInt8, 16)) for _=1:2^5]
traces = map(x -> (x, sample_function(x)), tracesO)
diff = DPA.generate_difference_trace(traces, DPA.select, 0x42, 1) # correct diff trace
diffWrong = DPA.generate_difference_trace(traces, DPA.select, 0x41, 1)
plt = plot([diff], label="Difference of Means", xlabel="Time", ylabel="Relative power consumption")
png(plt, "dpa_hamming_dom.png")

#  plt = plot(eachindex(traces[1][2]), traces[1][2], label="Sample trace", xlabel="Time", ylabel="Relative power consumption", ylims=(-20, 20))
#  vline!([argmax(diff)], label="First S-Box lookup")
#  png(plt, "dpa_trace_and_sbox_lookup_time.png")

function count_eps(traces, tr_select, pos)
  res = []
  for k = -15:15
      count = 0
      for x = traces
          if tr_select(x)
              check = x[2][pos]
              if k < check < k + 1
                  count += 1
              end
          end
      end
      append!(res, count)
  end
  res
end
  eps = count_eps(traces, _ -> true, argmax(diff))
  plt = plot(-15:15, eps, label="", xlabel="Recorded value", ylabel="# Occurences")
  png(plt, "dpa_values_at_sbox_lookup.png")

  eps_lsb1 = count_eps(traces, t -> DPA.select(t, 0x42, 1), argmax(diff))
  eps_lsb0 = count_eps(traces, t -> !DPA.select(t, 0x42, 1), argmax(diff))
  plt = plot(-15:15, [eps_lsb0, eps_lsb1], label=["Least significant bit is 0" "Least significant bit is 1"], xlabel="Recorded value", ylabel="# Occurences")
  display(plt)
  png(plt, "dpa_grouped_values_at_sbox_lookup.png")


#  recovered_key = DPA_AES_analyze(sample_function)
