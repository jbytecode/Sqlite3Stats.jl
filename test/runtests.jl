using Test
using Sqlite3Stats
using DataFrames
using Sqlite3Stats.SQLite



@testset "Functions" begin
    dbname, _ = mktemp()

    @info "Creating database: " dbname 
    db = SQLite.DB(dbname)

    @info "Creating test table"
    SQLite.execute(db, "create table Numbers (val float, otherval float)")
    x = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    for v in x
        y = 11.0 - v
        SQLite.execute(db, "insert into Numbers (val, otherval) values ($(v), $(y))")
    end

    @info "DB Content:"
    result = DBInterface.execute(db, "select val, otherval from Numbers") |> DataFrame 
    @show result

    Sqlite3Stats.register_functions(db)

    result = DBInterface.execute(db, "select val, otherval from Numbers") |> DataFrame
    @test size(result) == (10, 2)

    @testset "Q1" begin
        result = DBInterface.execute(db, "select count(val), Q1(val) as MYQ1 from Numbers") |> DataFrame
        @test result[!, "MYQ1"] == [3.25]
    end 

    @testset "Q2" begin
        result = DBInterface.execute(db, "select count(val), Q2(val) as MYQ2 from Numbers") |> DataFrame
        @test result[!, "MYQ2"] == [5.5]
    end 

    @testset "MEDIAN" begin
        result = DBInterface.execute(db, "select count(val), MEDIAN(val) as MYMEDIAN from Numbers") |> DataFrame
        @test result[!, "MYMEDIAN"] == [5.5]
    end 
    
    @testset "Q3" begin
        result = DBInterface.execute(db, "select count(val), Q3(val) as MYQ3 from Numbers") |> DataFrame
        @test result[!, "MYQ3"] == [7.75]
    end 

    @testset "COV" begin
        result = DBInterface.execute(db, "select COV(val, val) as MYCOV from Numbers") |> DataFrame
        @test result[!, "MYCOV"] == [9.166666666666666]
    end 

    @testset "COR" begin    
        result = DBInterface.execute(db, "select COR(val, val) as MYCOR from Numbers") |> DataFrame
        @test result[!, "MYCOR"] == [1.0]

        result = DBInterface.execute(db, "select COR(val, otherval) as MYCOR from Numbers") |> DataFrame
        @test result[!, "MYCOR"] == [-1.0]
    end 

    @testset "CORSPEARMAN" begin    
        result = DBInterface.execute(db, "select CORSPEARMAN(val, val) as MYCOR from Numbers") |> DataFrame
        @test result[!, "MYCOR"] == [1.0]

        result = DBInterface.execute(db, "select CORSPEARMAN(val, otherval) as MYCOR from Numbers") |> DataFrame
        @test result[!, "MYCOR"] == [-1.0]
    end 

    @testset "CORKENDALL" begin    
        result = DBInterface.execute(db, "select CORKENDALL(val, val) as MYCOR from Numbers") |> DataFrame
        @test result[!, "MYCOR"] == [1.0]

        result = DBInterface.execute(db, "select CORKENDALL(val, otherval) as MYCOR from Numbers") |> DataFrame
        @test result[!, "MYCOR"] == [-1.0]
    end 

    @testset "MAD" begin
        result = DBInterface.execute(db, "select MAD(val) as MYMAD from Numbers") |> DataFrame
        @test result[!, "MYMAD"] == [3.7065055462640046]
    end 

    @testset "IQR" begin
        result = DBInterface.execute(db, "select IQR(val) as MYIQR from Numbers") |> DataFrame
        @test result[!, "MYIQR"] == [4.5]
    end 

    @testset "SKEWNESS" begin
        result = DBInterface.execute(db, "select SKEWNESS(val) as MYSKEW from Numbers") |> DataFrame
        @test result[!, "MYSKEW"] == [0.0]
    end 

    @testset "KURTOSIS" begin
        result = DBInterface.execute(db, "select KURTOSIS(val) as MYKURT from Numbers") |> DataFrame
        @test result[!, "MYKURT"] == [-1.2242424242424244]
    end 

    @testset "GEOMEAN" begin
        result = DBInterface.execute(db, "select GEOMEAN(val) as MYGEOMEAN from Numbers") |> DataFrame
        @test result[!, "MYGEOMEAN"] == [4.528728688116766]
    end 

    @testset "HARMMEAN" begin
        result = DBInterface.execute(db, "select HARMMEAN(val) as MYHARMMEAN from Numbers") |> DataFrame
        @test result[!, "MYHARMMEAN"] == [3.414171521474055]
    end 

    @info "Closing db " dbname 
    SQLite.close(db)

    @info "Deleting db"
    rm(dbname)
end
