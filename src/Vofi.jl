module Vofi

# BinDeps
const depsfile = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if isfile(depsfile)
    include(depsfile)
else
    error("Vofi not properly installed.")
end

# package code goes here

end # module
