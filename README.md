# Sqlite3Stats
Injecting StatsBase functions into any SQLite database in Julia.

# Usage

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


