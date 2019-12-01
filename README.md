# FnMatch

Install via

    ] add https://github.com/venuur/FnMatch.jl

# Examples

For the following we load the package.

```julia
julia> using FnMatch
```

Create a regular expression that matches the Unix style pattern:

```julia
julia> translate("[xy][12].*")
r"(?s:[xy][12]\..*)\Z"
```

Determine if a name matches a pattern:

```julia
julia> fnmatchcase("data.csv", "*.csv")
true
```

Filter a list of names to only those that match a pattern:

```julia
julia> fnfilter(["x1.dat", "x2.csv", "xA.txt", "y1"], "[xy][12].*")
2-element Array{String,1}:
 "x1.dat"
 "x2.csv"
```
