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

# Covariance 
result = DBInterface.execute(db, "select COV(num, other) from table") |> DataFrame 

# Pearson Correlation 
result = DBInterface.execute(db, "select COR(num) from table") |> DataFrame 

# Spearman Correlation
result = DBInterface.execute(db, "select SPEARMANCOR(num) from table") |> DataFrame 

# Kendall Correlation
result = DBInterface.execute(db, "select KENDALLCOR(num) from table") |> DataFrame 

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


