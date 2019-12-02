using FnMatch
using Test

const filenames = [
    ".git",
    ".gitignore",
    "LICENSE",
    "Manifest.toml",
    "Project.toml",
    "README.md",
    "src",
    "test",
]

function test_filter_match(pat, expected, reference)
    for n in reference
        if n in expected
            @test fnmatchcase(n, pat)
        else
            @test !fnmatchcase(n, pat)
        end
    end
    @test all(fnfilter(reference, pat) .== expected)
end

@testset "FnMatch.jl" begin
    @testset "single range" begin
        pat = "[--P]*"
        expected = [".git", ".gitignore", "LICENSE", "Manifest.toml", "Project.toml"]
        test_filter_match(pat, expected, filenames)
    end  # Ranges open left

    @testset "multiple ranges" begin
        pat = "[L-Ns-t]*"
        expected = ["LICENSE", "Manifest.toml", "src", "test"]
        test_filter_match(pat, expected, filenames)
    end

    @testset "? wilcard" begin
        source = ["x1", "x2", "x", "xyz"]
        pat = "x?"
        expected = ["x1", "x2"]
        test_filter_match(pat, expected, source)
    end

    @testset "* wildcard" begin
        source = ["x12", "x22z", "abc", "xyz"]
        pat = "x*z"
        expected = ["x22z", "xyz"]
        test_filter_match(pat, expected, source)
    end

    @testset "negated character set" begin
        pat = "[!LMP]*"
        expected = [".git", ".gitignore", "README.md", "src", "test"]
        test_filter_match(pat, expected, filenames)
    end

end  # FnMatch
