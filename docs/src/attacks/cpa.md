# CPA

Intros CPA

## [Power estimation function](@id power_estimation_function)

Intros concept power estimation function. Some examples?



## Real-world attacks against AES
```@meta
CurrentModule = CSC.CPA.AES_RealWorld
```
The module `CSC.AES.AES_RealWorld` implements a real-world CPA attack against the
[Northeastern University](https://chest.coe.neu.edu/) TeSCASE dataset, which can be obtained [here](https://chest.coe.neu.edu/?current_page=POWER_TRACE_LINK&software=ptunmasked). The attacked traces have been generated on a [SASEBO board](https://www.risec.aist.go.jp/project/sasebo/) that executed the AES algorithm.


First, a power estimate for the real-world data has to be found. The paper "[Scalable and efficient implementation of correlation power analysis using graphics processing units](https://dl.acm.org/doi/10.1145/2611765.2611775)" suggests to use a Hamming distance estimation that targets the last round of AES. Roughly following the proposed algorithm in this paper, our implementation uses the following method to estimate power consumption:

```@docs
hamming_distance_power_estimate
```
