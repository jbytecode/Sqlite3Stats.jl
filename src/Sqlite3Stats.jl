module Sqlite3Stats

import Distributions
import StatsBase
import SQLite
import Logging

export StatsBase
export SQLite
export Distributions

export register_functions


function linear_regression(x::Array{Float64, 1}, y::Array{Float64, 1})::Array{Float64, 1}
    meanx = StatsBase.mean(x)
    meany = StatsBase.mean(y)
    beta1 = sum((x .- meanx) .* (y .- meany)) / sum( (x .- meanx) .* (x .- meanx))
    beta0 = meany - beta1 * meanx 
    return [beta0, beta1]
end

macro F64Vector()
    Array{Float64, 1}(undef, 0)
end

macro F64Matrix2()
    Array{Float64, 2}(undef, (0, 2))
end 

function register_functions(db::SQLite.DB; verbose::Bool = false)::Nothing

    # Saving the original logger and creating a local one
    # if verbose == true then the minimum level is Debug
    # so no output will be visible at runtime
    old_logger = Logging.global_logger()
    if verbose
        logger = Logging.ConsoleLogger(stdout, Logging.Info) 
    else
        logger = Logging.NullLogger()
    end
    Logging.global_logger(logger)


    @info "Registering Quantiles"
    SQLite.register(db, @F64Vector, 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.quantile(x, 0.25), 
        name = "Q1")

    SQLite.register(db, @F64Vector, 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.quantile(x, 0.50), 
        name = "Q2")

    SQLite.register(db, @F64Vector, 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.quantile(x, 0.50), 
        name = "MEDIAN")

    SQLite.register(db, @F64Vector, 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.quantile(x, 0.75), 
        name = "Q3")

    SQLite.register(db, @F64Matrix2, 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.quantile(x[:,1], x[1,2]), 
        name = "QUANTILE", nargs = 2)    

    @info "Registering covariance and correlation"
    SQLite.register(db, @F64Matrix2, 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.cov(x[:,1], x[:,2]), 
        name = "COV", nargs = 2)

    SQLite.register(db, @F64Matrix2, 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.cor(x[:,1], x[:,2]), 
        name = "COR", nargs = 2)

    SQLite.register(db, @F64Matrix2, 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.corspearman(x[:,1], x[:,2]), 
        name = "CORSPEARMAN", nargs = 2)
    
    SQLite.register(db, @F64Matrix2, 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.corkendall(x[:,1], x[:,2]), 
        name = "CORKENDALL", nargs = 2)

    @info "Registering location and scale functions"
    SQLite.register(db, @F64Vector, 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.geomean(x), 
        name = "GEOMEAN")

    SQLite.register(db, @F64Vector, 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.harmmean(x), 
        name = "HARMMEAN")

    SQLite.register(db, @F64Vector, 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.mode(x), 
        name = "MODE")


    # Maximum absolute deviations 
    SQLite.register(db, @F64Matrix2, 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.maxad(x[:,1], x[:,2]), 
        name = "MAXAD", nargs = 2)

    # Mean absolute deviations 
    SQLite.register(db, @F64Matrix2, 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.meanad(x[:,1], x[:,2]), 
        name = "MEANAD", nargs = 2)

    # Mean squared deviations 
    SQLite.register(db, @F64Matrix2, 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.msd(x[:,1], x[:,2]), 
        name = "MSD", nargs = 2)

    SQLite.register(db, @F64Vector, 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.mad(x, normalize = true), 
        name = "MAD")

    SQLite.register(db, @F64Vector, 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.iqr(x), 
        name = "IQR")

    @info "Registering moments"
    SQLite.register(db, @F64Vector, 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.skewness(x), 
        name = "SKEWNESS")

    SQLite.register(db, @F64Vector, 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.kurtosis(x), 
        name = "KURTOSIS")
    
    @info "Registering weighted functions"
    SQLite.register(db, @F64Matrix2, 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.mean(x[:,1], StatsBase.weights(x[:,2])), 
        name = "WMEAN", nargs = 2)

    SQLite.register(db, @F64Matrix2, 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.median(x[:,1], StatsBase.weights(x[:,2])), 
        name = "WMEDIAN", nargs = 2)

    SQLite.register(db, @F64Vector, 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.entropy(x), 
        name = "ENTROPY")

    @info "Ordinary least squares"
    SQLite.register(db, @F64Matrix2, 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> linear_regression(x[:,1], x[:,2])[2], 
        name = "LINSLOPE", nargs = 2)

    SQLite.register(db, @F64Matrix2, 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> linear_regression(x[:,1], x[:,2])[1], 
        name = "LININTERCEPT", nargs = 2)

    @info "Registering R like dx(), px(), qx(), rx() distribution functions"
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
    

    # qcauchy, pcauchy, rcauchy
    SQLite.register(db, (x, mu, sigma) -> Distributions.quantile(Distributions.Cauchy(mu, sigma), x), name = "QCAUCHY")
    
    SQLite.register(db, (x, mu, sigma) -> Distributions.cdf(Distributions.Cauchy(mu, sigma), x), name = "PCAUCHY")
    
    SQLite.register(db, (mu, sigma) -> rand(Distributions.Cauchy(mu, sigma)), name = "RCAUCHY")

    @info "Setting old logger as global"
    Logging.global_logger(old_logger)

    return nothing
end


end # module
