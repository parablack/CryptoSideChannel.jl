```@meta
CurrentModule = CryptoSideChannel.CPA
```
# CPA

## CPA attacks against AES

```@docs
CPA_AES_analyze
CPA_AES_analyze_traces
CPA_AES_analyze_manual
```

## CPA attacks against SPECK
Attacks against SPECK are a bit more difficult, since both key parts (the left 64 bits and the right 64 bits) have to be attacked differently.

```@docs
CPA_SPECK_analyze
CPA_SPECK_analyze_traces
```


## Real-world attacks against AES
In the file `test/aes-realworld`, a real-world CPA attack is implemented. This attack uses the
[Northeastern University](https://chest.coe.neu.edu/) TeSCASE dataset, available at the [TeSCASE downloads page](https://chest.coe.neu.edu/?current_page=POWER_TRACE_LINK&software=ptunmasked). The attacked traces have been generated on a [SASEBO board](https://www.risec.aist.go.jp/project/sasebo/) that executes the AES algorithm.