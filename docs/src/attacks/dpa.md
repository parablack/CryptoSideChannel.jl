# DPA


```@meta
CurrentModule = CryptoSideChannel.DPA
```

This framework implements differential power attacks against AES. On a high level, the attacks are implemented using the following two methods:

```@docs
DPA_AES_analyze_traces
DPA_AES_analyze
```

## Internal functions
Internally, DPA groups the traces into two partitions based on a key byte guess. This partitioning is created with the following method
```@docs
DPA_AES_select
```
