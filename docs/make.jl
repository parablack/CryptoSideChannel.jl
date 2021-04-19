push!(LOAD_PATH,"../src/")

using Documenter, CryptoSideChannel

makedocs(sitename="CryptoSideChannel.jl",
    modules = [CryptoSideChannel],
    pages = [
        "Home" => "index.md",
        "Ciphers" => "ciphers.md",
        "Types" => [
            "Integer Types" => "types/integer-types.md",
            "Logging" => "types/logging.md",
            "Masking" => "types/masking.md"
            ],
        "Attacks" => [
                "DPA" => "attacks/dpa.md",
                "CPA" => "attacks/cpa.md",
                "Template" => "attacks/template.md",
                ]
        ],
    repo = "https://github.com/parablack/CryptoSideChannel.jl"
    )
