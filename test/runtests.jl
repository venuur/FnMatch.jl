using FnMatch
using Test

const filenames = [
    ".git",
    ".gitignore",
    "LICENSE",
    "Manifest.toml",
    "Project.toml",
    "README.md",
    "scratch.jl",
    "src",
    "test",
]

@testset "FnMatch.jl" begin
    @testset "Ranges open left" begin
        expected = [".git", ".gitignore", "LICENSE", "Manifest.toml", "Project.toml"]
        pat = "[--P]*"
        for n in filenames
            if n in expected
                @test fnmatchcase(n, pat)
            else
                @test !fnmatchcase(n, pat)
            end
        end
        @test all(fnfilter(filenames, pat) .== expected)
    end  # Ranges open left
end  # FnMatch
