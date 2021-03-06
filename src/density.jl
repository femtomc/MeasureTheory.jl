"""
    struct Density{M,B}
        μ::M
        base::B
    end

For measures μ and ν with μ≪ν, the density of μ with respect to ν (also called
the Radon-Nikodym derivative dμ/dν) is a function f defined on the support of ν
with the property that for any measurable a ⊂ supp(ν), μ(a) = ∫ₐ f dν.
    
Because this function is often difficult to express in closed form, there are
many different ways of computing it. We therefore provide a formal
representation to allow comptuational flexibilty.
"""
struct Density{M,B,L}
    μ::M
    base::B
    log::L
end

export 𝒹

"""
    𝒹(μ::AbstractMeasure, base::AbstractMeasure; log=true)

Compute the Radom-Nikodym derivative (or its log, if `log=true`) of μ with
respect to `base`.
"""
function 𝒹(μ::AbstractMeasure, base::AbstractMeasure; log=true)
    return Density(μ, base, Val(log))
end

(f::Density{M,B,Val{true}})(x) where {M,B} = logdensity(f.μ, f.base, x) 

"""
    struct DensityMeasure{F,B} <: AbstractMeasure
        density :: F
        base    :: B
    end

A `DensityMeasure` is a measure defined by a density with respect to some other
"base" measure 
"""
struct DensityMeasure{F,B,L} <: AbstractMeasure
    f    :: F
    base :: B
    log  :: L
end

basemeasure(μ::DensityMeasure) = μ.base

logdensity(μ::DensityMeasure{F,B,Val{true}}, x) where {F,B} = μ.f(x)

export ∫

"""
    ∫(f, base::AbstractMeasure; log=true)

Define a new measure in terms of a density `f` over some measure `base`. If
`log=true` (the default), `f` is considered as a log-density.
"""
∫(f, base::AbstractMeasure; log=true) = DensityMeasure(f, base, Val(log))

# TODO: `density` and `logdensity` functions for `DensityMeasure`

function logdensity(μ::AbstractMeasure, ν::AbstractMeasure, x)
    bμ = basemeasure(μ)
    bν = basemeasure(ν)
        
    result = logdensity(μ,x) + logdensity(bμ,x)
    result -= logdensity(ν,x) + logdensity(bν, x) 
    result += _logdensity(basemeasure(bμ), basemeasure(bν), x)
end

_logdensity(::Lebesgue{ℝ}, ::Lebesgue{ℝ}, x) = zero(float(x))
