

file = joinpath(dirname(dirname(pathof(PlantBiophysics))), "test", "inputs", "models", "plant_coffee.yml")

@testset "read_model()" begin
    model = read_model(file)

    @test all([haskey(model, i) for i in ["Metamer", "Leaf"]])

    model = model["Leaf"]
    # @test typeof(model)
    @test typeof(model) <: ModelList
    @test typeof(model.models.stomatal_conductance) == Medlyn{Float64}
    @test typeof(model.models.interception) == Translucent{Float64}
    @test typeof(model.models.photosynthesis) == Fvcb{Float64}

    @test model.models.stomatal_conductance.g0 == -0.03
    @test model.models.stomatal_conductance.g1 == 12.0

    @test model.models.interception.transparency == 0.0
    @test model.models.interception.optical_properties == σ(0.15, 0.9)

    @test model.models.photosynthesis.VcMaxRef == 200.0 # Given in the file
    @test model.models.photosynthesis.O₂ == 210.0 # Use default value
end;

# Test reading the meteo:

file = joinpath(dirname(dirname(pathof(PlantBiophysics))), "test", "inputs", "meteo.csv")
var_names = Dict(:temperature => :T, :relativeHumidity => :Rh, :wind => :Wind, :atmosphereCO2_ppm => :Cₐ)

@testset "read_weather()" begin
    meteo = read_weather(
        file,
        :temperature => :T,
        :relativeHumidity => (x -> x ./ 100) => :Rh,
        :wind => :Wind,
        :atmosphereCO2_ppm => :Cₐ,
        :Re_SW_f => :Ri_SW_f,
        date_format=DateFormat("yyyy/mm/dd")
    )

    @test typeof(meteo) <: Weather
    @test typeof(meteo) <: Weather
    @test NamedTuple(meteo.metadata) == (; name="Aquiares", latitude=15.0, altitude=100.0, use=[:clearness], file=file)
end;