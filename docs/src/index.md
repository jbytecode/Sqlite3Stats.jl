# Sqlite3Stats.jl

Injecting StatsBase functions into any SQLite database in Julia.

## In Short
Makes it possible to call 

```sql
select MEDIAN(fieldname) from tablename
```

in Julia where median is defined in Julia and related packages and the function is *injected* to use within SQLite. **Database file is not modified**.

## Installation

```julia
julia> using Pkg
julia> Pkg.add("Sqlite3Stats")
```

## Simple use

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

