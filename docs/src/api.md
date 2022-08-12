# API references

## The Logic

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


