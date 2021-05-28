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

@safetestset "Logging masked values unit tests" begin
include("MaskLogging-test.jl")
end


@safetestset "AES unit tests" begin
include("AES-test.jl")
end
@safetestset "SPECK unit tests" begin
include("SPECK-test.jl")
end

@safetestset "faf0/AES integration tests" begin
include("aes-faf0/test.jl")
end

# Expensive tests: Comment out if testing is wished.
@safetestset "DPA unit tests" begin
include("DPA-test.jl")
end

# @safetestset "CPA/AES unit tests" begin
# include("CPA-AES-test.jl")
# end

# @safetestset "CPA/SPECK unit tests" begin
# include("CPA-SPECK-test.jl")
# end

# @safetestset "Template attack unit tests" begin
# include("Template-test.jl")
# end
