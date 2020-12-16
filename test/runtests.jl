using SafeTestsets, Test

@safetestset "AES unit tests" begin
include("AES-test.jl")
end
@safetestset "SPECK unit tests" begin
include("SPECK-test.jl")
end
