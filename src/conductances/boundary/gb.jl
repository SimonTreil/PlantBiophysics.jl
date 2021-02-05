"""
    gbₕ_free(Tₐ,Tₗ,Wₗ,Dₕ₀)
    gbₕ_free(Tₐ,Tₗ,Wₗ)

Leaf boundary layer conductance for heat under **free** convection (m s-1).

# Arguments

- `Tₐ` (°C): air temperature
- `Tₗ` (°C): leaf temperature
- `Wₗ` (m): leaf width (`d` in eq. 10.9 from Monteith and Unsworth, 2013).
- `Dₕ₀ = 21.5e-6`: molecular diffusivity for heat at base temperature. Use value from
[`Constants`](@Ref) if not provided.

# Note

`R` and `Dₕ₀` can be found using [`Constants`](@Ref). To transform in ``mol\\ m^{-2}\\ s^{-1}``,
use [`ms_to_mol`](@ref).

# References

Leuning, R., F. M. Kelliher, DGG de Pury, et E.-D. SCHULZE. 1995. « Leaf nitrogen,
photosynthesis, conductance and transpiration: scaling from leaves to canopies ». Plant,
Cell & Environment 18 (10): 1183‑1200.

Monteith, John, et Mike Unsworth. 2013. Principles of environmental physics: plants,
animals, and the atmosphere. Academic Press. Paragraph 10.1.3, eq. 10.9.
"""
function gbₕ_free(Tₐ,Tₗ,Wₗ,Dₕ₀)
    zeroT = zero(Tₐ) # make it type stable

    if (Tₗ-Tₐ) > zeroT
        Gr = 1.58e8 * Wₗ^3.0 * abs(Tₗ-Tₐ) # Grashof number (Monteith and Unsworth, 2013)
        # !Note: Leuning et al. (1995) use 1.6e8 (eq. E4).
        # Leuning et al. (1995) eq. E3:
        Gbₕ_free = 0.5 * get_Dₕ(Tₐ,Dₕ₀) * (Gr^0.25) / Wₗ
    else
        Gbₕ_free = zeroT
    end

    return Gbₕ_free
end

function gbₕ_free(Tₐ,Tₗ,Wₗ)
    zeroT = zero(Tₐ) # make it type stable
    constants = Constants()

    if (Tₗ-Tₐ) > zeroT
        Gr = 1.58e8 * Wₗ^3.0 * abs(Tₗ-Tₐ) # Grashof number (Monteith and Unsworth, 2013)
        # !Note: Leuning et al. (1995) use 1.6e8 (eq. E4).
        # Leuning et al. (1995) eq. E3:
        Gbₕ_free = 0.5 * get_Dₕ(Tₐ,constants.Dₕ₀) * (Gr^0.25) / Wₗ
    else
        Gbₕ_free = zeroT
    end

    return Gbₕ_free
end


"""
    gbₕ_forced(Wind,Wₗ)

Leaf boundary layer conductance for heat under **forced** convection (m s-1). See eq. E1 from
Leuning et al. (1995) for more details.

# Arguments

- `Wind` (m s-1): wind speed
- `Wₗ` (m): leaf width (`d` in eq. 10.9 from Monteith and Unsworth, 2013).

# References

Leuning, R., F. M. Kelliher, DGG de Pury, et E.-D. SCHULZE. 1995. « Leaf nitrogen,
photosynthesis, conductance and transpiration: scaling from leaves to canopies ». Plant,
Cell & Environment 18 (10): 1183‑1200.
"""
function gbₕ_forced(Wind,Wₗ)
    0.003 * sqrt(Wind/Wₗ)
end


"""
    get_Dₕ(T,Dₕ₀)
    get_Dₕ(T)

Dₕ -molecular diffusivity for heat at base temperature- from Dₕ₀ (corrected by temperature).
See Monteith and Unsworth (2013, eq. 3.10).

# Arguments

- `Tₐ` (°C): temperature
- `Dₕ₀`: molecular diffusivity for heat at base temperature. Use value from [`Constants`](@Ref)
if not provided.

# References

Monteith, John, et Mike Unsworth. 2013. Principles of environmental physics: plants,
animals, and the atmosphere. Academic Press. Paragraph 10.1.3., eq. 10.9.
"""
function get_Dₕ(T,Dₕ₀)
    Dₕ₀ + Dₕ₀ * (1 + 0.007*T)
end


function get_Dₕ(T)
    constants = Constants()
    constants.Dₕ₀ + constants.Dₕ₀ * (1 + 0.007*T)
end

"""
    gbh_to_gbw(gbh, Gbₕ_to_Gbₕ₂ₒ)
    gbh_to_gbw(gbh)

Boundary layer conductance for water vapor from boundary layer conductance for heat.

# Arguments

- `gbh` (m s-1): boundary layer conductance for heat under mixed convection.
- `Dₕ₀`: molecular diffusivity for heat at base temperature. Use value from [`Constants`](@Ref)
if not provided.

# Note

Gbₕ is the sum of free and forced convection. See [`gbₕ_free`](@ref) and [`gbₕ_forced`](@ref).
"""
function gbh_to_gbw(gbh, Gbₕ_to_Gbₕ₂ₒ)
    gbh * Gbₕ_to_Gbₕ₂ₒ
end


function gbh_to_gbw(gbh)
    gbh * Constants().Gbₕ_to_Gbₕ₂ₒ
end

"""
    gamma_star(Γ, a_sh, a_s, rbv, Rsᵥ, Rbₕ)

Γˢ, the CO₂ compensation point in the absence of day respiration (``mol_{CO_2}\\ mol^{-1}``).
Also called the apparent value of psychrometer constant.

# Arguments

- `Γ` (``mol_{CO_2}\\ mol^{-1}``): CO₂ compensation point
- `aₛₕ` (1,2): number of faces exchanging heat fluxes (see Schymanski et al., 2017)
- `aₛᵥ` (1,2): number of faces exchanging water fluxes (see Schymanski et al., 2017)
- `Rbᵥ` (s m-1): boundary layer resistance to water vapor
- `Rsᵥ` (s m-1): stomatal resistance to water vapor
- `Rbₕ` (s m-1): boundary layer resistance to heat

# Note

Using the corrigendum from Schymanski et al. (2017).

# References

Monteith, John L., et Mike H. Unsworth. 2013. « Chapter 13 - Steady-State Heat Balance: (i)
Water Surfaces, Soil, and Vegetation ». In Principles of Environmental Physics (Fourth Edition),
edited by John L. Monteith et Mike H. Unsworth, 217‑47. Boston: Academic Press.

Schymanski, Stanislaus J., et Dani Or. 2017. « Leaf-Scale Experiments Reveal an Important
Omission in the Penman–Monteith Equation ». Hydrology and Earth System Sciences 21 (2): 685‑706.
https://doi.org/10.5194/hess-21-685-2017.
"""
function gamma_star(Γ, aₛₕ, aₛᵥ, Rbᵥ, Rsᵥ, Rbₕ)
    Γ * aₛₕ / aₛᵥ * (Rbᵥ + Rsᵥ) / Rbₕ # rv + Rsᵥ= Boundary + stomatal conductance to water vapour
end