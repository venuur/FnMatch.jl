module FnMatch

export translate, fnmatchcase, fnfilter

"""
    fnmatchcase(name, pattern)

Test whether `name` matches `pattern`.

Patterns are Unix shell style:

    *       matches everything
    ?       matches any single character
    [seq]   matches any character in seq
    [!seq]  matches any char not in seq

An initial period in `name` is not special.
Both `name` and `pattern` are case sensitive regardless of the
operating system.

"""
function fnmatchcase(name, pat)
    re = translate(pat)
    return match(re, name) !== nothing
end


"""
    fnfilter(names, pattern)

Returns subset of `names` taht match `pattern`.

Equivalent to `[f for f in names if fnmatchcase(f)]` except optimized for batch
processing.

"""
function fnfilter(names, pat)
    re = translate(pat)
    return [n for n in names if match(re, n) !== nothing]
end

"""
    translate(pattern)

Translate a shell `pattern` to a regular expression.

There is no way to quote meta-characters.

"""
function translate(pat)
    i, n = firstindex(pat), lastindex(pat)
    res = ""
    while i <= n
        c = pat[i]
        i = nextind(pat, i)
        @debug "Start while" c i res
        if c == '*'
            res *= ".*"
        elseif c == '?'
            res *= "."
        elseif c == '['
            j = i
            if j <= n && pat[j] == '!'
                j = nextind(pat, j)
            end
            if j <= n && pat[j] == ']'
                j = nextind(pat, j)
            end
            while j <= n && pat[j] != ']'
                j = nextind(pat, j)
            end
            if j > n
                res *= "\\["
            else
                stuff = pat[i:prevind(pat, j)]
                @debug "in bracket" stuff
                if !occursin("--", stuff)
                    stuff = replace(stuff, "\\" => "\\\\")
                else
                    chunks = []
                    k = pat[i] == '!' ? nextind(pat, i, 2) : nextind(pat, i)
                    while true
                        f = findnext("-", pat, k)
                        if f === nothing || first(f) > j
                            break
                        end
                        k = first(f)
                        push!(chunks, pat[i:prevind(pat, k)])
                        i = nextind(pat, k)
                        k = nextind(pat, k, 3)
                    end
                    push!(chunks, pat[i:prevind(pat, j)])
                    # Escape backslashes and hyphens for set difference (--).
                    # Hyphens that create ranges shouldn't be escaped.
                    stuff = join(
                        map(chunks) do s
                            replace(replace(s, "\\" => "\\\\"), "-" => "\\-")
                        end,
                        "-",
                    )
                end
                # Escape set operations (&&, ~~, and ||).
                stuff = replace(stuff, r"([&~|])" => s"\\\1")
                i = nextind(pat, j)
                if first(stuff) == '!'
                    stuff_i2 = nextind(stuff, firstindex(stuff))
                    stuff = "^" * stuff[stuff_i2:end]
                elseif first(stuff) in ('^', '[')
                    stuff = "\\" * stuff
                end
                res = "$res[$stuff]"
            end
        else
            res *= escape(c)
        end
    end
    # In the reference implement of Python fnmatch there is not "\A" to start
    # the regex because Python's regex match only matches from the beginning by
    # default.
    Regex("\\A(?s:$(res))\\Z")
end

"""
    escape(character)

Returns `character` as string, escaping if it is special in `Regex`.

"""
function escape(c)
    # List of Regex special characters from
    #
    # https://github.com/python/cpython/blob/3.8/Lib/re.py#L261
    #
    # SPECIAL_CHARS
    # closing ')', '}' and ']'
    # '-' (a range in character set)
    # '&', '~', (extended character set operations)
    # '#' (comment) and WHITESPACE (ignored) in verbose mode
    # _special_chars_map = {
    #     i: '\\' + chr(i) for i in b'()[]{}?*+-|^$\\.&~# \t\n\r\v\f'}
    for special in "()[]{}?*+-|^\$\\.&~# \t\r\n\v\f"
        if c == special
            return string('\\', c)
        end
    end
    return string(c)
end

end # module
