using SafeTestsets, Test

@safetestset "Generic Log unit tests" begin
include("GenericLog-test.jl")
end

@safetestset "AES unit tests" begin
include("AES-test.jl")
end
@safetestset "SPECK unit tests" begin
include("SPECK-test.jl")
end

@safetestset "DPA unit tests" begin
include("DPA-test.jl")
end
