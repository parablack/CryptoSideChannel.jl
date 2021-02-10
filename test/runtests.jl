using SafeTestsets, Test

@safetestset "Generic Log unit tests" begin
include("GenericLog-test.jl")
end

@safetestset "Masking unit tests" begin
include("Masking-test.jl")
end

@safetestset "Higher-order masking unit tests" begin
include("HOMasking-test.jl")
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

@safetestset "CPA unit tests" begin
include("CPA-test.jl")
end
