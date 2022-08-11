# Sqlite3Stats
Injecting StatsBase functions into any SQLite database in Julia.

# In Short
Makes it possible to call 

```sql
select MEDIAN(fieldname) from tablename
```

in Julia where median is defined in Julia and related packages and the function is *injected* to use within SQLite. **Database file is not modified**.

# Installation

```julia
julia> using Pkg
julia> Pkg.add("Sqlite3Stats")
```

# Simple use

```julia
using SQLite
using Sqlite3Stats 
using DataFrames 

# Any SQLite database
# In our case, it is dbfile.db
db = SQLite.DB("dbfile.db")

# Injecting functions 
Sqlite3Stats.register_functions(db)
```

# Registered Functions and Examples

```Julia
using SQLite
using Sqlite3Stats 
using DataFrames 

db = SQLite.DB("dbfile.db")

# Injecting functions 
Sqlite3Stats.register_functions(db)

# 1st Quartile 
result = DBInterface.execute(db, "select Q1(num) from table") |> DataFrame 

# 2st Quartile 
result = DBInterface.execute(db, "select Q2(num) from table") |> DataFrame 

# Median (Equals to Q2) 
result = DBInterface.execute(db, "select MEDIAN(num) from table") |> DataFrame 

# 3rd Quartile 
result = DBInterface.execute(db, "select Q3(num) from table") |> DataFrame 

# QUANTILE
result = DBInterface.execute(db, "select QUANTILE(num, 0.25) from table") |> DataFrame 
result = DBInterface.execute(db, "select QUANTILE(num, 0.50) from table") |> DataFrame 
result = DBInterface.execute(db, "select QUANTILE(num, 0.75) from table") |> DataFrame 


# Covariance 
result = DBInterface.execute(db, "select COV(num, other) from table") |> DataFrame 

# Pearson Correlation 
result = DBInterface.execute(db, "select COR(num, other) from table") |> DataFrame 

# Spearman Correlation
result = DBInterface.execute(db, "select SPEARMANCOR(num, other) from table") |> DataFrame 

# Kendall Correlation
result = DBInterface.execute(db, "select KENDALLCOR(num, other) from table") |> DataFrame 

# Median Absolute Deviations 
result = DBInterface.execute(db, "select MAD(num) from table") |> DataFrame 

# Inter-Quartile Range
result = DBInterface.execute(db, "select IQR(num) from table") |> DataFrame 

# Skewness 
result = DBInterface.execute(db, "select SKEWNESS(num) from table") |> DataFrame 

# Kurtosis 
result = DBInterface.execute(db, "select KURTOSIS(num) from table") |> DataFrame 

# Geometric Mean
result = DBInterface.execute(db, "select GEOMEAN(num) from table") |> DataFrame 

# Harmonic Mean
result = DBInterface.execute(db, "select HARMMEAN(num) from table") |> DataFrame 

# Maximum absolute deviations
result = DBInterface.execute(db, "select MAXAD(num) from table") |> DataFrame 

# Mean absolute deviations
result = DBInterface.execute(db, "select MEANAD(num) from table") |> DataFrame 

# Mean squared deviations
result = DBInterface.execute(db, "select MSD(num) from table") |> DataFrame 

# Mode
result = DBInterface.execute(db, "select MODE(num) from table") |> DataFrame 

# WMEAN for weighted mean
result = DBInterface.execute(db, "select WMEAN(num, weights) from table") |> DataFrame 

# WMEDIAN for weighted mean
result = DBInterface.execute(db, "select WMEDIAN(num, weights) from table") |> DataFrame 

# Entropy
result = DBInterface.execute(db, "select ENTROPY(probs) from table") |> DataFrame 

# Slope (a) of linear regression y = b + ax
result = DBInterface.execute(db, "select LINSLOPE(x, y) from table") |> DataFrame 

# Intercept (b) of linear regression y = b + ax
result = DBInterface.execute(db, "select LININTERCEPT(x, y) from table") |> DataFrame 

# Quantile of Normal Distribution with mean 0 and standard deviation 1
result = DBInterface.execute(db, "select QNORM(1.96, 0.0, 1.0) from table") |> DataFrame 

# Probability of Normal Distribution with mean 0 and standard deviation 1
result = DBInterface.execute(db, "select PNORM(0.025, 0.0, 1.0) from table") |> DataFrame 

# Random number drawn from a Normal Distribution with mean * and standard deviation 1
result = DBInterface.execute(db, "select RNORM(0.0, 1.0) from table") |> DataFrame 

# Quantile of Student's T Distribution with degree of freedom 30
result = DBInterface.execute(db, "select QT(1.96, 30) from table") |> DataFrame 

# Probability of Student's T Distribution with degree of freedom 30
result = DBInterface.execute(db, "select PT(0.025, 30) from table") |> DataFrame 

# Random number drawn from a Student's T Distribution with degree of freedom 30
result = DBInterface.execute(db, "select RT(30) from table") |> DataFrame 


# Quantile of Chisquare Distribution with degree of freedom 30
result = DBInterface.execute(db, "select QCHISQ(1.96, 30) from table") |> DataFrame 

# Probability of Chisquare Distribution with degree of freedom 30
result = DBInterface.execute(db, "select PCHISQ(0.025, 30) from table") |> DataFrame 

# Random number drawn from a Chisquare Distribution with degree of freedom 30
result = DBInterface.execute(db, "select RCHISQ(30) from table") |> DataFrame 


# Quantile of F Distribution with degrees of freedom 30 and 32
result = DBInterface.execute(db, "select QF(0.025, 30, 32) from table") |> DataFrame 

# Probability of F Distribution with degrees of freedom 30 and 32
result = DBInterface.execute(db, "select PF(5, 30, 32) from table") |> DataFrame 

# Random number drawn from a F Distribution with degrees of freedom 30 and 32
result = DBInterface.execute(db, "select RF(30, 32) from table") |> DataFrame 


# Quantile of Poisson Distribution with mean (lambda) 5
result = DBInterface.execute(db, "select QPOIS(0.05, 5) from table") |> DataFrame 

# Probability of Poisson Distribution with mean (lambda) 5
result = DBInterface.execute(db, "select PPOIS(3, 5) from table") |> DataFrame 

# Random number drawn from a Poisson Distribution with mean (lambda) 5
result = DBInterface.execute(db, "select RPOIS(5) from table") |> DataFrame 


# Quantile of Binomial Distribution with n = 10 and p = 0.5 
result = DBInterface.execute(db, "select QBINOM(0.05, 10, 0.5) from table") |> DataFrame 

# Probability of Binomial Distribution with n = 10 and p = 0.5 
result = DBInterface.execute(db, "select PBINOM(5, 10, 0.5) from table") |> DataFrame 

# Random number drawn from a Binomial Distribution with = 10 and p = 0.5 
result = DBInterface.execute(db, "select RPOIS(10, 0.5) from table") |> DataFrame 


# Quantile of Uniform Distribution with a = 0, b = 10
result = DBInterface.execute(db, "select QUNIF(0.05, 0, 10) from table") |> DataFrame 

# Probability of Uniform Distribution with a = 0, b = 0 
result = DBInterface.execute(db, "select PUNIF(5, 0, 10) from table") |> DataFrame 

# Random number drawn from a Uniform Distribution with  a = 0 and b = 10 
result = DBInterface.execute(db, "select RUNIF(0, 10) from table") |> DataFrame 


# Quantile of Exponential Distribution with lambda = 10
result = DBInterface.execute(db, "select QEXP(0.05, 10) from table") |> DataFrame 

# Probability of Exponential Distribution with lambda = 10 
result = DBInterface.execute(db, "select PEXP(5, 10) from table") |> DataFrame 

# Random number drawn from a Exponential Distribution with lambda = 10
result = DBInterface.execute(db, "select REXP(10) from table") |> DataFrame 


# Quantile of Beta Distribution with a = 10 and b = 20
result = DBInterface.execute(db, "select QBETA(0.05, 10, 20) from table") |> DataFrame 

# Probability of Beta Distribution with a = 10 and b = 20
result = DBInterface.execute(db, "select PBETA(5, 10, 20) from table") |> DataFrame 

# Random number drawn from a Beta Distribution with a = 10 and b = 20
result = DBInterface.execute(db, "select RBETA(10, 20) from table") |> DataFrame 

# Quantile of Cauchy Distribution with location 10, scale 20
result = DBInterface.execute(db, "select QCAUCHY(0.05, 10, 20) from table") |> DataFrame 

# Probability of Cauchy Distribution with with location 10, scale 20
result = DBInterface.execute(db, "select PCAUCHY(5, 10, 20) from table") |> DataFrame 

# Random number drawn from a Cauchy Distribution with location 10, scale 20
result = DBInterface.execute(db, "select RCAUCHY(10, 20) from table") |> DataFrame 
```

# Other functions for distributions
Note that Q, P, and R prefix correspond to Quantile, CDF (Probability), and Random (number), respectively.

- `QGAMMA(x, alpha, theta)`, `PGAMMA(x, alpha, theta)`, `RGAMMA(alpha, theta)`
- `QFRECHET(x, alpha)`, `PFRECHET(x, alpha)`, `RFRECHET(alpha)`
- `QPARETO(x, alpha, theta)`, `PPARETO(x, alpha, theta)`, `RPARETO(alpha, theta)`
- `QWEIBULL(x, alpha, theta)`, `PWEIBULL(x, alpha, theta)`, `RWEIBULL(alpha, theta)`


# Hypothesis Tests
- `JB(x)` for Jarque-Bera Normality Test (returns the p-value)


# The Logic

The package mainly uses the ```register``` function. For example, a single variable 
function ```MEDIAN``` is registered as 

```julia
SQLite.register(db, [], 
        (x,y) -> vcat(x, y), 
        x -> StatsBase.quantile(x, 0.50), 
        name = "MEDIAN")
```

whereas, the two-variable function ```COR``` is registered as 

```julia
SQLite.register(db, Array{Float64, 2}(undef, (0, 2)), 
        (x, a, b) -> vcat(x, [a, b]'), 
        x -> StatsBase.cor(x[:,1], x[:,2]), 
        name = "COR", nargs = 2)
```

for Pearson's correlation coefficient. 


