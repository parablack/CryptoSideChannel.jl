push!(LOAD_PATH,"../src/")

using Documenter, CSC

makedocs(sitename="Crypto-Side-Channel",
    modules = [CSC],
    pages = [
        "Home" => "index.md",
        "Ciphers" => "ciphers.md",
        "Types" => [
            "Integer Types" => "types/integer-types.md",
            "Logging" => "types/logging.md",
            "Masking" => "types/masking.md"
            ],
        "Attacks" => "attacks.md"],
    repo = "https://github.com/parablack/crypto-side-channel"
    )
