module Sqlite3Stats

import StatsBase
import SQLite

export StatsBase
export SQLite


function register_functions(db::SQLite.DB; verbose::Bool = true)::Nothing

    if verbose
        @info "Registering Q1"
    end
    SQLite.register(db, [], 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.quantile(x, 0.25), 
        name = "Q1")

    SQLite.register(db, [], 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.quantile(x, 0.50), 
        name = "Q2")

    SQLite.register(db, [], 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.quantile(x, 0.50), 
        name = "MEDIAN")

    SQLite.register(db, [], 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.quantile(x, 0.75), 
        name = "Q3")

    SQLite.register(db, Array{Float64, 2}(undef, (0, 2)), 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.quantile(x[:,1], x[1,2]), 
        name = "QUANTILE", nargs = 2)    

    SQLite.register(db, Array{Float64, 2}(undef, (0, 2)), 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.cov(x[:,1], x[:,2]), 
        name = "COV", nargs = 2)

    SQLite.register(db, Array{Float64, 2}(undef, (0, 2)), 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.cor(x[:,1], x[:,2]), 
        name = "COR", nargs = 2)

    SQLite.register(db, Array{Float64, 2}(undef, (0, 2)), 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.corspearman(x[:,1], x[:,2]), 
        name = "CORSPEARMAN", nargs = 2)
    
    SQLite.register(db, Array{Float64, 2}(undef, (0, 2)), 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.corkendall(x[:,1], x[:,2]), 
        name = "CORKENDALL", nargs = 2)

    # Maximum absolute deviations 
    SQLite.register(db, Array{Float64, 2}(undef, (0, 2)), 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.maxad(x[:,1], x[:,2]), 
        name = "MAXAD", nargs = 2)

    # Mean absolute deviations 
    SQLite.register(db, Array{Float64, 2}(undef, (0, 2)), 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.meanad(x[:,1], x[:,2]), 
        name = "MEANAD", nargs = 2)

    # Mean squared deviations 
    SQLite.register(db, Array{Float64, 2}(undef, (0, 2)), 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.msd(x[:,1], x[:,2]), 
        name = "MSD", nargs = 2)

    SQLite.register(db, [], 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.mad(convert(Array{Float64, 1}, x)), 
        name = "MAD")

    SQLite.register(db, [], 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.iqr(convert(Array{Float64, 1}, x)), 
        name = "IQR")

    SQLite.register(db, [], 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.skewness(convert(Array{Float64, 1}, x)), 
        name = "SKEWNESS")

    SQLite.register(db, [], 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.kurtosis(convert(Array{Float64, 1}, x)), 
        name = "KURTOSIS")
    
    SQLite.register(db, [], 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.geomean(convert(Array{Float64, 1}, x)), 
        name = "GEOMEAN")

    SQLite.register(db, [], 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.harmmean(convert(Array{Float64, 1}, x)), 
        name = "HARMMEAN")

    SQLite.register(db, [], 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.mode(convert(Array{Float64, 1}, x)), 
        name = "MODE")

    SQLite.register(db, Array{Float64, 2}(undef, (0, 2)), 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.mean(x[:,1], StatsBase.weights(x[:,2])), 
        name = "WMEAN", nargs = 2)

    SQLite.register(db, Array{Float64, 2}(undef, (0, 2)), 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.median(x[:,1], StatsBase.weights(x[:,2])), 
        name = "WMEDIAN", nargs = 2)

    SQLite.register(db, [], 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.entropy(convert(Array{Float64, 1}, x)), 
        name = "ENTROPY")

    return nothing
end


export register_functions

end # module
