var documenterSearchIndex = {"docs":
[{"location":"types/masking/#Masking","page":"Masking","title":"Masking","text":"","category":"section"},{"location":"types/masking/","page":"Masking","title":"Masking","text":"CurrentModule = CryptoSideChannel.Masking","category":"page"},{"location":"types/masking/","page":"Masking","title":"Masking","text":"Masked","category":"page"},{"location":"types/masking/#CryptoSideChannel.Masking.Masked","page":"Masking","title":"CryptoSideChannel.Masking.Masked","text":"struct Masked{M, T1, T2}\n    val::T1\n    mask::T2\nend\n\nThe Masked datatype behaves like an integer, but splits its internal value into two shares. Hence, the plain value held by a Masked type should not be observable in memory\n\nwarning: Warning\nThe above statement holds only in theory. See the article on problems with high-level software masking for details on this problem.\n\nType Arguments\n\nM is the way in which the underlying value is masked. M can be either Boolean or Arithmetic, representing boolean masking or arithmetic masking, respectively.\nT1 is the type of the first share. This can be any integer-like type: A primitive integer, a GenericLog type, or another Masked type for higher-order masking.\nT2 is the type of the second share. This should always be either a primitive integer type, or a GenericLog type.\n\n\n\n\n\n","category":"type"},{"location":"types/masking/","page":"Masking","title":"Masking","text":"It may be useful to extract the content of a Masked type, for example at the end of a cryptographic calculation.","category":"page"},{"location":"types/masking/","page":"Masking","title":"Masking","text":"unmask","category":"page"},{"location":"types/masking/#CryptoSideChannel.Masking.unmask","page":"Masking","title":"CryptoSideChannel.Masking.unmask","text":"unmask(a::Masked)\n\nUnmask the contained integer by calculating val ⊻ mask, or val + mask respectively.\n\nNote that this function is unsafe with respect to side-channels. After calling this function, the data will no longer be split into two shares. Thus, this method should only be called at the end of a cryptographic algorithm to extract the final result.\n\n\n\n\n\n","category":"function"},{"location":"types/masking/#Masking-Types","page":"Masking","title":"Masking Types","text":"","category":"section"},{"location":"types/masking/#boolean_masking","page":"Masking","title":"Boolean Masking","text":"","category":"section"},{"location":"types/masking/","page":"Masking","title":"Masking","text":"BooleanMask","category":"page"},{"location":"types/masking/#CryptoSideChannel.Masking.BooleanMask","page":"Masking","title":"CryptoSideChannel.Masking.BooleanMask","text":"BooleanMask(v)\n\nCreate a masked integer holding value v. Internally, v will be stored in two shares, val and mask, such that v = val ⊻ mask. The latter condition is an invariant of this datatype.\n\nIt should always be the case that mask is a primitive type, i.e. of the type Integer or GenericLog. If higher-order masking is desired, val can be of the type Masked.\n\n\n\n\n\n","category":"function"},{"location":"types/masking/#arithmetic_masking","page":"Masking","title":"Arithmetic Masking","text":"","category":"section"},{"location":"types/masking/","page":"Masking","title":"Masking","text":"ArithmeticMask","category":"page"},{"location":"types/masking/#CryptoSideChannel.Masking.ArithmeticMask","page":"Masking","title":"CryptoSideChannel.Masking.ArithmeticMask","text":"ArithmeticMask(v)\n\nCreate a masked integer holding value v. Internally, v will be stored in two shares, val and mask, such that v = val - mask. The latter condition is an invariant of this datatype.\n\nIt should always be the case that mask is a primitive type, i.e. of the type Integer or GenericLog. If higher-order masking is desired, val can be of the type Masked.\n\n\n\n\n\n","category":"function"},{"location":"types/masking/#Conversion","page":"Masking","title":"Conversion","text":"","category":"section"},{"location":"types/masking/","page":"Masking","title":"Masking","text":"arithmeticToBoolean\nbooleanToArithmetic","category":"page"},{"location":"types/masking/#CryptoSideChannel.Masking.arithmeticToBoolean","page":"Masking","title":"CryptoSideChannel.Masking.arithmeticToBoolean","text":"arithmeticToBoolean(a::Masked{Arithmetic})::Masked{Boolean}\n\nExecute the algorithm outlined in Goubin's paper to convert from algebraic shares to boolean shares.\n\nSee also: arithmeticToBoolean\n\n\n\n\n\n","category":"function"},{"location":"types/masking/#CryptoSideChannel.Masking.booleanToArithmetic","page":"Masking","title":"CryptoSideChannel.Masking.booleanToArithmetic","text":"booleanToArithmetic(a::Masked{Boolean})::Masked{Arithmetic}\n\nExecute the algorithm outlined in Goubin's paper to convert from boolean shares to algebraic shares.\n\nSee also: arithmeticToBoolean\n\n\n\n\n\n","category":"function"},{"location":"types/masking/#masking_problems","page":"Masking","title":"Problems with High-level Masking","text":"","category":"section"},{"location":"types/masking/","page":"Masking","title":"Masking","text":"TODO.","category":"page"},{"location":"types/masking/","page":"Masking","title":"Masking","text":"Purport: Compiler optimisations may kill all guarantees. This is for educational / testing purposes only! Do not compile with this tool and expect everything to be safe...","category":"page"},{"location":"attacks/cpa/#CPA","page":"CPA","title":"CPA","text":"","category":"section"},{"location":"attacks/cpa/","page":"CPA","title":"CPA","text":"Intros CPA","category":"page"},{"location":"attacks/cpa/#power_estimation_function","page":"CPA","title":"Power estimation function","text":"","category":"section"},{"location":"attacks/cpa/","page":"CPA","title":"CPA","text":"Intros concept power estimation function. Some examples?","category":"page"},{"location":"attacks/cpa/#Real-world-attacks-against-AES","page":"CPA","title":"Real-world attacks against AES","text":"","category":"section"},{"location":"attacks/cpa/","page":"CPA","title":"CPA","text":"CurrentModule = CryptoSideChannel.CPA.AES_RealWorld","category":"page"},{"location":"attacks/cpa/","page":"CPA","title":"CPA","text":"The module CryptoSideChannel.AES.AES_RealWorld implements a real-world CPA attack against the Northeastern University TeSCASE dataset, which can be obtained here. The attacked traces have been generated on a SASEBO board that executed the AES algorithm.","category":"page"},{"location":"attacks/cpa/","page":"CPA","title":"CPA","text":"First, a power estimate for the real-world data has to be found. The paper \"Scalable and efficient implementation of correlation power analysis using graphics processing units\" suggests to use a Hamming distance estimation that targets the last round of AES. Roughly following the proposed algorithm in this paper, our implementation uses the following method to estimate power consumption:","category":"page"},{"location":"attacks/cpa/","page":"CPA","title":"CPA","text":"hamming_distance_power_estimate","category":"page"},{"location":"attacks/cpa/#CryptoSideChannel.CPA.AES_RealWorld.hamming_distance_power_estimate","page":"CPA","title":"CryptoSideChannel.CPA.AES_RealWorld.hamming_distance_power_estimate","text":"hamming_distance_power_estimate(ciphertext, key_guess_index, key_guess)\n\nA power estimation function targeting the last round of AES under the Hamming distance model, suitable for the real-word data provided. For more information on power estimation, see the main section.\n\n\n\n\n\n","category":"function"},{"location":"types/logging/#logging","page":"Logging","title":"Logging: The GenericLog Datatype","text":"","category":"section"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"CurrentModule = CryptoSideChannel.Logging\nDocTestSetup = quote\n    using CryptoSideChannel\nend","category":"page"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"Logging.GenericLog","category":"page"},{"location":"types/logging/#CryptoSideChannel.Logging.GenericLog","page":"Logging","title":"CryptoSideChannel.Logging.GenericLog","text":"struct GenericLog{U,S,T}\n    val::T\nend\n\nThe GenericLog datatype behaves like an integer, but additionally logs a trace of all values contained. Technically, this type logs its reduced value every time a operation is performed on it.\n\nType Arguments\n\nT is the underlying type that the logging should be performed upon. T may be a primitive integer type (like UInt8 or Int), or any integer-like type (for example, another instance of GenericLog or a Masked integer).\nU should be a container holding a reduction function. The purpose of this reduction function is to preprocess all single values stores in this type. Most commonly, only a value derived from the intermediate values should be logged, like the Hamming weight, or the least significant bit. The reduction function should compute this value. More on this topic can be found at the chapter on Reduction functions.\nS is a closure returning the array where values should be logged to. Note that S must be a bits type. This can only be the case if the array returned by S is a global variable.\n\n\n\n\n\n","category":"type"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"Most operations on integers can also be performed on instances of GenericLog. By default, this includes the most common operations like calculations, array accesses, and more. However, it is easy to extend this functionality to other methods if desired. See the chapter on Defining new methods for GenericLog types for more details.","category":"page"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"It may be useful to extract the content of a GenericLog type, for example at the end of a cryptographic calculation.","category":"page"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"Logging.extractValue","category":"page"},{"location":"types/logging/#CryptoSideChannel.Logging.extractValue","page":"Logging","title":"CryptoSideChannel.Logging.extractValue","text":"extractValue(a::GenericLog)\nextractValue(a::Integer)\n\nExtracts the internal value from the GenericLog datatype. Behaves like the identity function if an Integer value is passed.\n\n\n\n\n\n","category":"function"},{"location":"types/logging/#Pre-defined-logging-types","page":"Logging","title":"Pre-defined logging types","text":"","category":"section"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"There are already several logging datatypes pre-defined. Creating instances of those types is as easy as specifying a closure returning the logging destination, and the underlying value.","category":"page"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"The following logging types are already pre-defined:","category":"page"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"HammingWeightLog\nFullLog\nSingleBitLog\nStochasticLog","category":"page"},{"location":"types/logging/#CryptoSideChannel.Logging.HammingWeightLog","page":"Logging","title":"CryptoSideChannel.Logging.HammingWeightLog","text":"HammingWeightLog(val, stream)\n\nCreates a logging datatype that logs the Hamming weight of the underlying value.\n\nArguments\n\nval: the value that should be wrapped around.\nstream: A closure returning the array that should be logged to. Note that stream must be a bits type.\n\nExample\n\nDocTestSetup = quote\n    using CryptoSideChannel\nend\n\njulia> trace = [];\n\njulia> closure = () -> trace;\n\njulia> a = Logging.HammingWeightLog(42, closure)\nLog{Int64, 42}\njulia> b = a + 1\nLog{Int64, 43}\njulia> c = a - 42\nLog{Int64, 0}\njulia> trace\n2-element Vector{Any}:\n 4\n 0\n\nNotice that (43)_10 = (101011)_2. Hence, the Hamming weight of 43 is 4.\n\n\n\n\n\n","category":"function"},{"location":"types/logging/#CryptoSideChannel.Logging.FullLog","page":"Logging","title":"CryptoSideChannel.Logging.FullLog","text":"FullLog(val, stream)\n\nCreates a logging datatype that logs the full underlying value.\n\nArguments\n\nval: the value that should be wrapped around.\nstream: A closure returning the array that should be logged to. Note that stream must be a bits type.\n\nExample\n\nDocTestSetup = quote\n    using CryptoSideChannel\nend\n\njulia> trace = [];\n\njulia> closure = () -> trace;\n\njulia> a = Logging.FullLog(42, closure)\nLog{Int64, 42}\njulia> b = a + 1\nLog{Int64, 43}\njulia> c = a - 42\nLog{Int64, 0}\njulia> trace\n2-element Vector{Any}:\n 43\n  0\n\n\n\n\n\n","category":"function"},{"location":"types/logging/#CryptoSideChannel.Logging.SingleBitLog","page":"Logging","title":"CryptoSideChannel.Logging.SingleBitLog","text":"SingleBitLog(val, stream, bit)\n\nCreates a logging datatype that logs the value of a single bit of the underlying value. The bit that is logged is selected with the bit argument.\n\nArguments\n\nval: the value that should be wrapped around.\nstream: A closure returning the array that should be logged to. Note that stream must be a bits type.\nbit: The position of the bit that should be logged, where 0 is the least significant bit.\n\n\n\n\n\n","category":"function"},{"location":"types/logging/#Reduction-functions","page":"Logging","title":"Reduction functions","text":"","category":"section"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"A reduction function for a GenericLog over base type T should take any value of type T, and produce any result that eventually is logged. Reasonable choices for reduction functions could be a model of side-channel emissions. For example, the Hamming weight could be a reasonable model which is already pre-defined. However, this framework allows free choices of reduction functions, hence providing great flexibility.","category":"page"},{"location":"types/logging/#Single-Function-Log","page":"Logging","title":"Single Function Log","text":"","category":"section"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"Most reduction functions simply take the intermemdiate value and output the reduced result. The type SingleFunctionLog captures this pattern.","category":"page"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"SingleFunctionLog","category":"page"},{"location":"types/logging/#CryptoSideChannel.Logging.SingleFunctionLog","page":"Logging","title":"CryptoSideChannel.Logging.SingleFunctionLog","text":"abstract type SingleFunctionLog{F} <: LogFunction end\n\nA wrapper for simple reduction functions that take a single argument and output a reduced value.\n\n\n\n\n\n","category":"type"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"For example, it is possible to define the HammingWeightLog based on this method as follows:","category":"page"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"HammingWeightLog(val, stream)  =\n    GenericLog{SingleFunctionLog{Base.count_ones},stream,typeof(val)}(val)","category":"page"},{"location":"types/logging/#Creating-your-own-reduction-function","page":"Logging","title":"Creating your own reduction function","text":"","category":"section"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"TODO hamming distance, explain custom logValue","category":"page"},{"location":"types/logging/#extending_log_funs","page":"Logging","title":"Defining new methods for GenericLog types","text":"","category":"section"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"TODO: Either explain","category":"page"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"function Base.$op(a::Integer, b::GenericLog{U,S}) where {U,S}\n    res = Base.$op(extractValue(a), extractValue(b))\n    result = GenericLog{U,S,typeof(res)}(res)\n    push!(typeof(b).parameters[2](), logValue(result))\n    result\nend","category":"page"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"pattern or include generic code like","category":"page"},{"location":"types/logging/","page":"Logging","title":"Logging","text":"registerFunction(Base.:(+))","category":"page"},{"location":"attacks/dpa/","page":"DPA","title":"DPA","text":"Attacks","category":"page"},{"location":"attacks/dpa/#DPA","page":"DPA","title":"DPA","text":"","category":"section"},{"location":"attacks/dpa/","page":"DPA","title":"DPA","text":"TBD","category":"page"},{"location":"attacks/template/#Template","page":"Template","title":"Template","text":"","category":"section"},{"location":"attacks/template/","page":"Template","title":"Template","text":"CurrentModule = CryptoSideChannel.TemplateAttacks","category":"page"},{"location":"attacks/template/","page":"Template","title":"Template","text":"Template","category":"page"},{"location":"attacks/template/#CryptoSideChannel.TemplateAttacks.Template","page":"Template","title":"CryptoSideChannel.TemplateAttacks.Template","text":"The Template struct stores a noise distribution, as well as values for integers that are logged.\n\nIf the integer x is logged, a random vector from distribution is drawn. Then, values[x] is added to this random vector.\n\n\n\n\n\n","category":"type"},{"location":"attacks/template/","page":"Template","title":"Template","text":"random_diagonal_multivariate_distribution\nrandom_uncorrelated_template","category":"page"},{"location":"attacks/template/#CryptoSideChannel.TemplateAttacks.random_diagonal_multivariate_distribution","page":"Template","title":"CryptoSideChannel.TemplateAttacks.random_diagonal_multivariate_distribution","text":"random_diagonal_multivariate_distribution(d::Integer)\n\nGenerate a random normal multivariate distribution over d dimensions. The mean will be a vector chosen randomly from 0 1^d.\n\nNote that all random values are uncorrelated. Hence, our covariance matrix is a diagonal matrix.\n\n\n\n\n\n","category":"function"},{"location":"attacks/template/#CryptoSideChannel.TemplateAttacks.random_uncorrelated_template","page":"Template","title":"CryptoSideChannel.TemplateAttacks.random_uncorrelated_template","text":"random_uncorrelated_template(dimensions::Integer, max_value::Integer)\n\nGenerate a random template over d dimensions, that supports operations on integers between 0 and max_value.\n\n\n\n\n\n","category":"function"},{"location":"attacks/template/","page":"Template","title":"Template","text":"LikelyKey","category":"page"},{"location":"attacks/template/#CryptoSideChannel.TemplateAttacks.LikelyKey","page":"Template","title":"CryptoSideChannel.TemplateAttacks.LikelyKey","text":"This struct merges different key bytes for which probabilities are known to a whole key, by iterating first over keys that are more likely.\n\nKeys are stored as lists of lists, where the outer lists represent the respective key byte (i.e. the first list represents the first key byte). The inner lists must be sorted according to the probability of a specific byte occuring.\n\n\n\n\n\n","category":"type"},{"location":"types/create-traces/#Creating-your-own-side-channel-traces","page":"Create your own traces","title":"Creating your own side-channel traces","text":"","category":"section"},{"location":"types/create-traces/","page":"Create your own traces","title":"Create your own traces","text":"TODO text!","category":"page"},{"location":"types/create-traces/","page":"Create your own traces","title":"Create your own traces","text":"One of the main features of this project is the ability to create traces of your own cryptographic algorithms.","category":"page"},{"location":"types/create-traces/","page":"Create your own traces","title":"Create your own traces","text":"We will look at AES as an example on how to create your own side-channel traces using this framework:","category":"page"},{"location":"types/create-traces/#Unmasked-traces","page":"Create your own traces","title":"Unmasked traces","text":"","category":"section"},{"location":"types/create-traces/","page":"Create your own traces","title":"Create your own traces","text":"trace = []\n\nfunction encrypt_collect_trace(pt::MVector{16, UInt8})\n    global trace\n    trace = []\n    clos = () -> trace\n    d = Distributions.Normal(0, 2)\n\n    reduce_function = x -> Base.count_ones(x) + rand(d)\n\n    kl = map(x -> Logging.SingleFunctionLog(x, clos, reduce_function), hex2bytes(SECRET_KEY))\n    ptl = map(x -> Logging.SingleFunctionLog(x, clos, reduce_function), pt)\n\n    AES.AES_encrypt(ptl, kl)\n\n    return copy(trace)\nend","category":"page"},{"location":"types/create-traces/#Masked-traces","page":"Create your own traces","title":"Masked traces","text":"","category":"section"},{"location":"types/create-traces/","page":"Create your own traces","title":"Create your own traces","text":"coll = []\n\nfunction encrypt_collect_masked_trace(pt::MVector{16, UInt8})\n    global coll\n    global key\n    coll = []\n    clos = () -> coll\n\n    reduce_function = x -> Base.count_ones(x)\n\n    kl = map(x -> Masking.BooleanMask(Logging.SingleFunctionLog(x, clos, reduce_function)), key)\n    ptl = map(x -> Masking.BooleanMask(Logging.SingleFunctionLog(x, clos, reduce_function)), pt)\n\n    output = (Logging.extractValue ∘ Masking.unmask).(AES.AES_encrypt(ptl, kl))\n\n    return (output, copy(coll))\nend","category":"page"},{"location":"types/integer-types/#integer_types","page":"Integer Types","title":"Integer Types","text":"","category":"section"},{"location":"types/integer-types/","page":"Integer Types","title":"Integer Types","text":"Duck typing.\nWhat methods are needed exactly?\nDefine type similarity\nDefine primitive integer type","category":"page"},{"location":"types/integer-types/#Subclass-of-Integer","page":"Integer Types","title":"Subclass of Integer","text":"","category":"section"},{"location":"types/integer-types/","page":"Integer Types","title":"Integer Types","text":"Discuss why this may be a bad idea? Search example from notes.","category":"page"},{"location":"#CryptoSideChannel.jl:-A-customizable-side-channel-modelling-and-analysis-framework-in-Julia","page":"Home","title":"CryptoSideChannel.jl: A customizable side-channel modelling and analysis framework in Julia","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This library focuses on generic side-channel analysis of various cryptographic algorithms. This implementation uses custom types that behave like integers. However, those types may additionally log their values, or mask the internal representation of their values. In combination, this allows for easy recording of side-channels for educational and testing purposes.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This project is split into three parts:","category":"page"},{"location":"#Ciphers","page":"Home","title":"Ciphers","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Currently, two ciphers are implemented: The SPECK cipher, and the AES cipher suite.","category":"page"},{"location":"","page":"Home","title":"Home","text":"CryptoSideChannel.AES","category":"page"},{"location":"#CryptoSideChannel.AES","page":"Home","title":"CryptoSideChannel.AES","text":"This module provides an implementation of the AES algorithm.\n\nFurther documentation can be found at AES.\n\n\n\n\n\n","category":"module"},{"location":"","page":"Home","title":"Home","text":"CryptoSideChannel.SPECK","category":"page"},{"location":"#CryptoSideChannel.SPECK","page":"Home","title":"CryptoSideChannel.SPECK","text":"This module implements the SPECK cipher.\n\nMore documentation can be found in the chapter SPECK.\n\n\n\n\n\n","category":"module"},{"location":"#Custom-Types","page":"Home","title":"Custom Types","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package currently provides two classes of additional types that mimic integers.","category":"page"},{"location":"","page":"Home","title":"Home","text":"See the Integer Types page for a more detailed explanation on how to declare custom integer types.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The GenericLog type allows for recording traces of program executions.\nThe Masked type internally splits its value into two shares. Thus, the content of a Masked integer should never be observable in memory.","category":"page"},{"location":"","page":"Home","title":"Home","text":"CryptoSideChannel.Logging","category":"page"},{"location":"#CryptoSideChannel.Logging","page":"Home","title":"CryptoSideChannel.Logging","text":"The Logging module allows for recording traces of program executions. This module provides the type GenericLog, which can be substituted for an integer. With this type, arithmetic operations, as well as certain memory operations will be logged to a trace array.\n\nFurther documentation is available at Logging.\n\n\n\n\n\n","category":"module"},{"location":"","page":"Home","title":"Home","text":"CryptoSideChannel.Masking","category":"page"},{"location":"#CryptoSideChannel.Masking","page":"Home","title":"CryptoSideChannel.Masking","text":"The Masking module provides integer types that mask values. Hence, those values do never occur in memory while operations on it are performed. This makes side-channel attacks more difficult.\n\nFurther documentation is available at Masking.\n\n\n\n\n\n","category":"module"},{"location":"#Attacks","page":"Home","title":"Attacks","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Multiple side-channel attacks against the ciphers above have been implemented:","category":"page"},{"location":"","page":"Home","title":"Home","text":"DPA\nCPA\nTemplate Attacks","category":"page"},{"location":"","page":"Home","title":"Home","text":"CryptoSideChannel.DPA","category":"page"},{"location":"#CryptoSideChannel.DPA","page":"Home","title":"CryptoSideChannel.DPA","text":"The DPA module implements generic Differential Power Attacks. The implementation largely follows the one described by Kocher in this paper, but is generalized to support other cryptographic algorithms.\n\nA detailed documentation can be found at DPA\n\n\n\n\n\n","category":"module"},{"location":"","page":"Home","title":"Home","text":"CryptoSideChannel.CPA","category":"page"},{"location":"#CryptoSideChannel.CPA","page":"Home","title":"CryptoSideChannel.CPA","text":"The CPA module implements generic Correlation Power Attacks.\n\nMore documentation is available at CPA\n\n\n\n\n\n","category":"module"},{"location":"","page":"Home","title":"Home","text":"CryptoSideChannel.TemplateAttacks","category":"page"},{"location":"#CryptoSideChannel.TemplateAttacks","page":"Home","title":"CryptoSideChannel.TemplateAttacks","text":"This module implements Template attacks on cryptographic side channels.\n\nMore information can be found at Template\n\n\n\n\n\n","category":"module"},{"location":"ciphers/#Ciphers","page":"Ciphers","title":"Ciphers","text":"","category":"section"},{"location":"ciphers/#AES","page":"Ciphers","title":"AES","text":"","category":"section"},{"location":"ciphers/","page":"Ciphers","title":"Ciphers","text":"CurrentModule = CryptoSideChannel.AES","category":"page"},{"location":"ciphers/#Encryption-and-Decryption","page":"Ciphers","title":"Encryption and Decryption","text":"","category":"section"},{"location":"ciphers/","page":"Ciphers","title":"Ciphers","text":"The following two methods provide a basic interface for encrypting and decrypting. Both methods are parametrised over the underlying type for the computations.","category":"page"},{"location":"ciphers/","page":"Ciphers","title":"Ciphers","text":"For simply using AES, one would instantiate T as UInt8. For more advanced settings that log traces or use masking, refer to the respective chapters.  TODO references","category":"page"},{"location":"ciphers/","page":"Ciphers","title":"Ciphers","text":"AES_encrypt\nAES_decrypt","category":"page"},{"location":"ciphers/#CryptoSideChannel.AES.AES_encrypt","page":"Ciphers","title":"CryptoSideChannel.AES.AES_encrypt","text":"AES_encrypt(plaintext::MVector{16,T}, key::Vector{T})::MVector{16,T} where T\n\nEncrypt a block of 16 bytes with AES.\n\nT must behave similarly to UInt8. For instantiating T with logging or protecting types, see the article on Integer Types.     TODO references to the relevant types chapter.\n\nArguments\n\nplaintext must be a mutable, statically sized Vector of length 16. It contains the text to encrypt.\nkey is a vector containing the key used for the encryption. It must be either of length 16, 24, or 32.   Depending on its length, different variants of AES are dispatched:\nLength 16: AES-128\nLength 24: AES-196\nLength 32: AES-256\n\nReturns\n\nA MVector{16,T} containing the 16-byte long encrypted block.\n\n\n\n\n\n","category":"function"},{"location":"ciphers/#CryptoSideChannel.AES.AES_decrypt","page":"Ciphers","title":"CryptoSideChannel.AES.AES_decrypt","text":"AES_decrypt(ciphertext::MVector{16,T}, key::Vector{T})::MVector{16,T} where T\n\nDecrypt a block of 16 bytes with AES.\n\nT must behave similarly to UInt8. For instantiating T with logging or protecting types, see the article on Integer Types.     TODO references to the relevant types chapter.\n\nArguments\n\nciphertext must be a mutable, statically sized Vector of length 16. It contains the data to decrypt.\nkey is a vector containing the key used for the decryption. It must be either of length 16, 24, or 32.   Depending on its length, different variants of AES are dispatched:\nLength 16: AES-128\nLength 24: AES-196\nLength 32: AES-256\n\nReturns\n\nA MVector{16,T} containing the 16-byte long decrypted block.\n\n\n\n\n\n","category":"function"},{"location":"ciphers/","page":"Ciphers","title":"Ciphers","text":"This module also exports methods to en-/decrypt data given as a hexadecimal string:","category":"page"},{"location":"ciphers/","page":"Ciphers","title":"Ciphers","text":"AES_encrypt_hex\nAES_decrypt_hex","category":"page"},{"location":"ciphers/#CryptoSideChannel.AES.AES_encrypt_hex","page":"Ciphers","title":"CryptoSideChannel.AES.AES_encrypt_hex","text":"AES_encrypt_hex(plaintext::String, key::String)\n\nInterpret plaintext and key in hexadecimal. Return a string containing the hexadecimal encrypted block. See AES_encrypt for more details.\n\nExample\n\njulia> AES_encrypt_hex(\"00112233445566778899aabbccddeeff\", \"000102030405060708090a0b0c0d0e0f\")\n\"69c4e0d86a7b0430d8cdb78070b4c55a\"\n\n\n\n\n\n","category":"function"},{"location":"ciphers/#CryptoSideChannel.AES.AES_decrypt_hex","page":"Ciphers","title":"CryptoSideChannel.AES.AES_decrypt_hex","text":"AES_decrypt_hex(ciphertext::String, key::String)\n\nInterpret ciphertext and key in hexadecimal. Return a string containing the hexadecimal decrypted block. See AES_decrypt for more details.\n\nExample\n\njulia> AES_decrypt_hex(\"69c4e0d86a7b0430d8cdb78070b4c55a\", \"000102030405060708090a0b0c0d0e0f\")\n\"00112233445566778899aabbccddeeff\"\n\n\n\n\n\n","category":"function"},{"location":"ciphers/#AES-Internal-Functions","page":"Ciphers","title":"AES Internal Functions","text":"","category":"section"},{"location":"ciphers/","page":"Ciphers","title":"Ciphers","text":"AES.key_expand\nAES.inv_key_expand","category":"page"},{"location":"ciphers/#CryptoSideChannel.AES.key_expand","page":"Ciphers","title":"CryptoSideChannel.AES.key_expand","text":"key_expand(k::Vector{T})\n\nCompute the AES key schedule\n\nArguments\n\nk is the key for the AES algorithm. It should be a vector of type T, which must be an UInt8-like type.   The key is required to be a valid key for AES-128, AES-196, or AES-256. Hence, k must be either 16, 24, or 32 bytes long.\n\nReturns\n\nAn vector of type T containing the whole key schedule.\n\n\n\n\n\n","category":"function"},{"location":"ciphers/#CryptoSideChannel.AES.inv_key_expand","page":"Ciphers","title":"CryptoSideChannel.AES.inv_key_expand","text":"inv_key_expand(k::Vector{T})\n\nCompute the AES key schedule given only the last round key. This is useful for attacks targeting the last round key, or for computing the decryption key on-the-fly.\n\nwarning: Warning\nThis algorithm is currently only implemented for AES-128.\n\nArguments\n\nk is the last round key used in the AES algorithm. It should be a vector of type T, which must be an UInt8-like type.   The key is required to be a valid round key for AES. Hence, k must be exactly 16 bytes long.\n\nReturns\n\nAn vector of type T containing the whole key schedule. Most importantly, the first 16 bytes of this vector are the original AES-128 key.\n\nExample\n\njulia> key = hex2bytes(\"000102030405060708090a0b0c0d0e0f\")\njulia> last_round_key = AES.key_expand(key)[end-15:end]\njulia> recovered_key = AES.inv_key_expand(last_round_key)[1:16]\njulia> bytes2hex(recovered_key)\n\"000102030405060708090a0b0c0d0e0f\"\n\n\n\n\n\n","category":"function"},{"location":"ciphers/#SPECK","page":"Ciphers","title":"SPECK","text":"","category":"section"},{"location":"ciphers/","page":"Ciphers","title":"Ciphers","text":"CurrentModule = CryptoSideChannel.SPECK","category":"page"},{"location":"ciphers/#Encryption-and-Decryption-2","page":"Ciphers","title":"Encryption and Decryption","text":"","category":"section"},{"location":"ciphers/","page":"Ciphers","title":"Ciphers","text":"SPECK.SPECK_encrypt\nSPECK.SPECK_decrypt","category":"page"},{"location":"ciphers/#CryptoSideChannel.SPECK.SPECK_encrypt","page":"Ciphers","title":"CryptoSideChannel.SPECK.SPECK_encrypt","text":"SPECK_encrypt(plaintext::Tuple{T, T}, key::Tuple{T, T}; rounds = 32)::Tuple{T,T} where T\n\nEncrypt plaintext using key with SPECK.\n\nArguments\n\nplaintext is 128-bit data, split into two shares of type T. Each share should contain 64 bits of the plaintext. T can be either UInt64 or a similar custom integer type.\nkey is the 128-bit key, split into two shares of type T. Each share should contain 64 bits of the plaintext. T can be either UInt64 or a similar custom integer type.\nrounds is the number of rounds to execute. Defaults to 32, since this is the number of rounds mentioned in the original specification of SPECK.\n\nReturns\n\nA Tuple{T,T} containing the 128-bit encrypted data in two shares of 64 bit.\n\nnote: Note\nT can be a custom integer type, but note that T must behave like UInt64. This includes truncating overflows in additions at 64 bit.\n\nExample\n\nThe example is a SPECK128 test vector from the original SPECK paper\n\njulia> key = (0x0f0e0d0c0b0a0908, 0x0706050403020100)\njulia> plaintext = (0x6c61766975716520, 0x7469206564616d20)\njulia> SPECK.SPECK_encrypt(plaintext, key)\n(0xa65d985179783265, 0x7860fedf5c570d18)\n\n\n\n\n\n\n\n","category":"function"},{"location":"ciphers/#CryptoSideChannel.SPECK.SPECK_decrypt","page":"Ciphers","title":"CryptoSideChannel.SPECK.SPECK_decrypt","text":"SPECK_decrypt(ciphertext::Tuple{T, T}, key::Tuple{T, T}; rounds = 32)::Tuple{T,T} where T\n\nDecrypt ciphertext using key with SPECK.\n\nArguments\n\nciphertext is 128-bit data, split into two shares of type T. Each share should contain 64 bits of the plaintext. T can be either UInt64 or a similar custom integer type.\nkey is the 128-bit key, split into two shares of type T. Each share should contain 64 bits of the plaintext. T can be either UInt64 or a similar custom integer type.\nrounds is the number of rounds to execute. Defaults to 32, since this is the number of rounds mentioned in the original specification of SPECK.\n\nReturns\n\nA Tuple{T,T} containing the 128-bit encrypted data in two shares of 64 bit.\n\nnote: Note\nT can be a custom integer type, but note that T must behave like UInt64. This includes truncating overflows in additions at 64 bit.\n\nExample\n\nThe example is a SPECK128 test vector from the original SPECK paper\n\njulia> key = (0x0f0e0d0c0b0a0908, 0x0706050403020100)\njulia> plaintext = (0x6c61766975716520, 0x7469206564616d20)\njulia> SPECK.SPECK_decrypt(ciphertext, key)\n(0x6c61766975716520, 0x7469206564616d20)\n\n\n\n\n\n\n\n","category":"function"},{"location":"ciphers/#Internal-Functions","page":"Ciphers","title":"Internal Functions","text":"","category":"section"},{"location":"ciphers/","page":"Ciphers","title":"Ciphers","text":"SPECK.SPECK_key_expand","category":"page"},{"location":"ciphers/#CryptoSideChannel.SPECK.SPECK_key_expand","page":"Ciphers","title":"CryptoSideChannel.SPECK.SPECK_key_expand","text":"SPECK_key_expand(key::Tuple{T, T}, rounds)::Vector{T} where T\n\nExpand the key according to the SPECK key schedule. The result is a vector of length rounds, containing each round key. The first round key is the second component of key.\n\n\n\n\n\n","category":"function"}]
}