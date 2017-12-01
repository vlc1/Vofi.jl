__precompile__()

module Vofi

export get_fh, get_cc

# BinDeps
const depsfile = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if isfile(depsfile)
    include(depsfile)
else
    error("Vofi not properly installed.")
end

# package code goes here

# from src/getfc.c
# ix0=0: use the default value for x
# ix0=1: point x is given
const ix = 1

# typedef double (*integrand)(void*, vofi_creal []);
function generic_integrand_2d(func, x_::Ptr{Cdouble})
    x = unsafe_wrap(Array, x_, (2,))
    return func(x)
end
function generic_integrand_3d(func, x_::Ptr{Cdouble})
    x = unsafe_wrap(Array, x_, (3,))
    return func(x)
end

#
integrand_ptr_2d{T}(integrand::T) = cfunction(generic_integrand_2d,
    Cdouble, (Ref{T}, Ptr{Cdouble}))
integrand_ptr_3d{T}(integrand::T) = cfunction(generic_integrand_3d,
    Cdouble, (Ref{T}, Ptr{Cdouble}))

#
function get_fh{T}(integrand::T, x::Vector{<:Real}, h::Real)
    ndim = size(x, 1)
    if ndim == 2
        ptr = integrand_ptr_2d(integrand)
    else
        ptr = integrand_ptr_3d(integrand)
    end
    return ccall((:vofi_Get_fh, libvofi),
        Cdouble,
        (Ptr{Void}, Any, Ref{Cdouble}, Cdouble, Cint, Cint),
        ptr, integrand, x, h, ndim, ix)
end


#
function get_cc{T}(integrand::T, x::Vector{<:Real}, h::Real, fh::Real)
    ndim = size(x, 1)
    if ndim == 2
        ptr = integrand_ptr_2d(integrand)
    else
        ptr = integrand_ptr_3d(integrand)
    end
    return ccall((:vofi_Get_cc, libvofi),
        Cdouble,
        (Ptr{Void}, Any, Ref{Cdouble}, Cdouble, Cdouble, Cint),
        ptr, integrand, x, h, fh, ndim)
end

end # module
