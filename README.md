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
```

# Well-known Probability Related Functions 
This family of functions implement QXXX(), PXXX(), and RXXX() for a probability density or mass function XXX. Q for quantile, p for propability or cdf value, R for random number. 

`QNORM(p, mean, stddev)` returns the quantile value $q$ 

whereas 

`PNORM(q, mean, stddev)` returns $p$ using the equation

$$
\int_{-\infty}^{q} f(x; \mu, \sigma)dx = p
$$


and `RNORM(mean, stddev)` draws a random number from a Normal distribution with mean `mean` ($\mu$) and standard deviation `stddev` ($\sigma$) which is defined as 

$$
f(x; \mu, \sigma) = \frac{1}{\sigma\sqrt{2\pi}} e^{-\frac{1}{2} (\frac{x-\mu}{\sigma})^2}
$$

and $-\infty < x < \infty$.

```julia
# Quantile of Normal Distribution with mean 0 and standard deviation 1
result = DBInterface.execute(db, "select QNORM(0.025, 0.0, 1.0) from table") |> DataFrame 

# Probability of Normal Distribution with mean 0 and standard deviation 1
result = DBInterface.execute(db, "select PNORM(-1.96, 0.0, 1.0) from table") |> DataFrame 

# Random number drawn from a Normal Distribution with mean * and standard deviation 1
result = DBInterface.execute(db, "select RNORM(0.0, 1.0) from table") |> DataFrame 
```

# Other functions for distributions
Note that Q, P, and R prefix correspond to Quantile, CDF (Probability), and Random (number), respectively. 

- `QT(x, dof)`, `PT(x, dof)`, `RT(dof)` for Student-T Distribution
- `QCHISQ(x, dof)`, `PCHISQ(x, dof)`, `RCHISQ(dof)` for ChiSquare Distribution 
- `QF(x, dof1, dof2)`, `PF(x, dof1, dof2)`, `RF(dof1, dof2)` for F Distribution 
- `QPOIS(x, lambda)`,`RPOIS(x, lambda)`, `RPOIS(lambda)` for Poisson Distribution 
- `QBINOM(x, n, p)`, `PBINOM(x, n, p)`, `RBINOM(n, p)` for Binomial Distribution
- `QUNIF(x, a, b)`, `PUNIF(x, a, b)`, `RUNIF(a, b)` for Uniform Distribution 
- `QEXP(x, theta)`, `PEXP(x, theta)`, `REXP(theta)` for Exponential Distribution 
- `QBETA(x, alpha, beta)`, `PGAMMA(x, alpha, beta)`, `RGAMMA(alpha, beta)` for Beta Distribution
- `QCAUCHY(x, location, scale)`, `PCAUCHY(x, location, scale)`, `RCAUCHY(location, scale)` for Cauchy Distribution
- `QGAMMA(x, alpha, theta)`, `PGAMMA(x, alpha, theta)`, `RGAMMA(alpha, theta)` for Gamma Distribution
- `QFRECHET(x, alpha)`, `PFRECHET(x, alpha)`, `RFRECHET(alpha)` for Frechet Distribution
- `QPARETO(x, alpha, theta)`, `PPARETO(x, alpha, theta)`, `RPARETO(alpha, theta)` for Pareto Distribution
- `QWEIBULL(x, alpha, theta)`, `PWEIBULL(x, alpha, theta)`, `RWEIBULL(alpha, theta)` for Weibull Distribution


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


