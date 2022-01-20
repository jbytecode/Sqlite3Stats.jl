module Sqlite3Stats

import Distributions
import StatsBase
import SQLite

export StatsBase
export SQLite
export Distributions

function linear_regression(x::Array{Float64, 1}, y::Array{Float64, 1})::Array{Float64, 1}
    meanx = StatsBase.mean(x)
    meany = StatsBase.mean(y)
    beta1 = sum((x .- meanx) .* (y .- meany)) / sum( (x .- meanx) .* (x .- meanx))
    beta0 = meany - beta1 * meanx 
    return [beta0, beta1]
end


function register_functions(db::SQLite.DB; verbose::Bool = true)::Nothing

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

    SQLite.register(db, Array{Float64, 2}(undef, (0, 2)), 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> linear_regression(x[:,1], x[:,2])[2], 
        name = "LINSLOPE", nargs = 2)

    SQLite.register(db, Array{Float64, 2}(undef, (0, 2)), 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> linear_regression(x[:,1], x[:,2])[1], 
        name = "LININTERCEPT", nargs = 2)

    # qnorm, pnorm, rnorm
    SQLite.register(db, (x, mu, sd) -> Distributions.quantile(Distributions.Normal(mu, sd), x), name = "QNORM")
    
    SQLite.register(db, (x, mu, sd) -> Distributions.pdf(Distributions.Normal(mu, sd), x), name = "PNORM")
    
    SQLite.register(db, (mu, sd) -> rand(Distributions.Normal(mu, sd)), name = "RNORM")
    
    # qt, pt, rt
    SQLite.register(db, (x, dof) -> Distributions.quantile(Distributions.TDist(dof), x), name = "QT")
    
    SQLite.register(db, (x, dof) -> Distributions.cdf(Distributions.TDist(dof), x), name = "PT")
    
    SQLite.register(db, (dof) -> rand(Distributions.TDist(dof)), name = "RT")

    # qchisq, pchisq, rchisq
    SQLite.register(db, (x, dof) -> Distributions.quantile(Distributions.Chisq(dof), x), name = "QCHISQ")
    
    SQLite.register(db, (x, dof) -> Distributions.cdf(Distributions.Chisq(dof), x), name = "PCHISQ")
    
    SQLite.register(db, (dof) -> rand(Distributions.Chisq(dof)), name = "RCHISQ")
    
    # qf, pf, rf
    SQLite.register(db, (x, dof1, dof2) -> Distributions.quantile(Distributions.FDist(dof1, dof2), x), name = "QF")
    
    SQLite.register(db, (x, dof1, dof2) -> Distributions.cdf(Distributions.FDist(dof1, dof2), x), name = "PF")
    
    SQLite.register(db, (dof1, dof2) -> rand(Distributions.FDist(dof1, dof2)), name = "RF")
    

    # qpois, ppois, rpois
    SQLite.register(db, (x, lambda) -> Distributions.quantile(Distributions.Poisson(lambda), x), name = "QPOIS")
    
    SQLite.register(db, (x, lambda) -> Distributions.cdf(Distributions.Poisson(lambda), x), name = "PPOIS")
    
    SQLite.register(db, (lambda) -> rand(Distributions.Poisson(lambda)), name = "RPOIS")
    

    # qbinom, pbinom, rbinom
    SQLite.register(db, (x, n, p) -> Distributions.quantile(Distributions.Binomial(n, p), x), name = "QBINOM")
    
    SQLite.register(db, (x, n, p) -> Distributions.cdf(Distributions.Binomial(n, p), x), name = "PBINOM")
    
    SQLite.register(db, (n, p) -> rand(Distributions.Binomial(n, p)), name = "RBINOM")


    # qrunif, prunif, runif
    SQLite.register(db, (x, a, b) -> Distributions.quantile(Distributions.Uniform(a, b), x), name = "QUNIF")
    
    SQLite.register(db, (x, a, b) -> Distributions.cdf(Distributions.Uniform(a, b), x), name = "PUNIF")
    
    SQLite.register(db, (a, b) -> rand(Distributions.Uniform(a, b)), name = "RUNIF")
    

    # qexp, pexp, rexp
    SQLite.register(db, (x, theta) -> Distributions.quantile(Distributions.Exponential(theta), x), name = "QEXP")
    
    SQLite.register(db, (x, theta) -> Distributions.cdf(Distributions.Exponential(theta), x), name = "PEXP")
    
    SQLite.register(db, (theta) -> rand(Distributions.Exponential(theta)), name = "REXP")
    

    # qbeta, pbeta, rbeta
    SQLite.register(db, (x, alpha, beta) -> Distributions.quantile(Distributions.Beta(alpha, beta), x), name = "QBETA")
    
    SQLite.register(db, (x, alpha, beta) -> Distributions.cdf(Distributions.Beta(alpha, beta), x), name = "PBETA")
    
    SQLite.register(db, (alpha, beta) -> rand(Distributions.Beta(alpha, beta)), name = "RBETA")
    
    return nothing
end


export register_functions

end # module
