constants = Constants()

# Monteith, John L., et Mike H. Unsworth. 2013. « Chapter 13 - Steady-State Heat Balance: (i)
# Water Surfaces, Soil, and Vegetation ». In Principles of Environmental Physics (Fourth Edition),
# edited by John L. Monteith et Mike H. Unsworth, 217‑47. Boston: Academic Press.

# p 230:

# In Monteith and Unsworth (2013) p.230, they say at a standard pressure of 101.3 kPa,
# λ has a value of about 66 Pa K−1 at 0 ◦C increasing to 67 Pa K−1 at 20 ◦C:
@testset "Psychrometer constant" begin
    λ₀ = latent_heat_vaporization(0.0, constants.λ₀)
    @test psychrometer_constant(101.3, λ₀) * 1000 ≈ 65.9651894869062 # in Pa K-1
    λ₂₀ = latent_heat_vaporization(20.0, constants.λ₀)
    @test psychrometer_constant(101.3, λ₂₀) * 1000 ≈ 67.23680111943287 # in Pa K-1
end;

@testset "Black body" begin
    # Testing that both calls return the same value with default parameters:
    @test black_body(25.0, constants.K₀, constants.σ) == black_body(25.0)
    @test black_body(25.0, constants.K₀, constants.σ) ≈ 448.07517457669354 # checked
end;


@testset "grey body" begin
    # Testing that both calls return the same value with default parameters:
    @test grey_body(25.0, 0.96, constants.K₀, constants.σ) == grey_body(25.0, 0.96)
    @test grey_body(25.0, 0.96, constants.K₀, constants.σ) ≈ 430.1521675936258
end;


@testset "Rₗₗ" begin
    # Testing that both calls return the same value with default parameters:
    @test net_longwave_radiation(25.0, 20.0, 0.955, 1.0, 1.0, constants.K₀, constants.σ) ==
            net_longwave_radiation(25.0, 20.0, 0.955, 1.0, 1.0)
    # Example from Cengel (2003), Example 12-7 (p. 627):
    # Cengel, Y, et Transfer Mass Heat. 2003. A practical approach. New York, NY, USA: McGraw-Hill.
    @test net_longwave_radiation(526.85, 226.85000000000002, 0.2, 0.7, 1.0, constants.K₀, constants.σ) ≈ -3625.6066521315793
    # NB: we compute it opposite (negative when energy is lost, positive for a gain)
end;



@testset "energy_balance(LeafModels{.,Monteith{Float64,Int64},Fvcb{Float64},Medlyn{Float64},.})" begin
    # Reference value:
    ref = (
        Rₛ = 13.747,
        skyFraction = 1.0,
        d = 0.03,
        Tₗ = 17.659873993789848,
        Rn = 21.266393383716945,
        Rₗₗ = 7.5193933837169435,
        H = -121.49817112628988,
        λE = 142.76456451000684,
        Cₛ = 356.330207843304,
        Cᵢ = 337.0202128385702,
        A = 29.35278783520552,
        Gₛ = 1.506586807729961,
        Gbₕ = 0.021346792818908434,
        Dₗ = 0.5021715623565368,
        Gbc = 0.6721531380291846,
        iter = 2.0,
        PPFD = 1500.0
    )

    meteo = Atmosphere(T = 20.0, Wind = 1.0, P = 101.3, Rh = 0.65)
    leaf = LeafModels(energy = Monteith(),
                photosynthesis = Fvcb(),
                stomatal_conductance = Medlyn(0.03, 12.0),
                Rₛ = 13.747, skyFraction = 1.0, PPFD = 1500.0, d = 0.03)

    non_mutating = energy_balance(leaf, meteo)

    for i in keys(ref)
        @test non_mutating.status[i] ≈ ref[i]
    end

    # Mutating the leaf:
    energy_balance!(leaf, meteo)
    for i in keys(ref)
        @test leaf.status[i] ≈ ref[i]
    end
end;



# meteo = Atmosphere(T = 20.0, Wind = 1.0, P = 101.3, Rh = 0.65)
# leaf = LeafModels(energy = Monteith(),
#             photosynthesis = Fvcb(),
#             stomatal_conductance = Medlyn(0.03, 12.0),
#             Rₛ = 13.747, skyFraction = 1.0, PPFD = 1500.0, d = 0.03)

# res = DataFrame(:PPFD => Float64[], :A => Float64[])
# for i in 1:10:1500
#     leaf.status.PPFD = i
#     energy_balance!(leaf, meteo)
#     push!(res, (PPFD = leaf.status.PPFD, A = leaf.status.A))
# end


# plot(res.PPFD,res.A)
# ylabel!("A")
# xlabel!("PPFD")


# Add tests for several components and/or several meteo time-steps (Weather)
