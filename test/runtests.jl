using Test
using Sqlite3Stats
using DataFrames
using Sqlite3Stats.SQLite



@testset "Functions" begin
    db = SQLite.DB()

    SQLite.execute(db, "create table Numbers (val float, otherval float)")
    x = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    for v in x
        y = 11.0 - v
        SQLite.execute(db, "insert into Numbers (val, otherval) values ($(v), $(y))")
    end

    result = DBInterface.execute(db, "select val, otherval from Numbers") |> DataFrame

    Sqlite3Stats.register_functions(db)

    result = DBInterface.execute(db, "select val, otherval from Numbers") |> DataFrame
    @test size(result) == (10, 2)

    @testset "Q1" begin
        result =
            DBInterface.execute(db, "select count(val), Q1(val) as MYQ1 from Numbers") |>
            DataFrame
        @test result[!, "MYQ1"] == [3.25]
    end

    @testset "Q2" begin
        result =
            DBInterface.execute(db, "select count(val), Q2(val) as MYQ2 from Numbers") |>
            DataFrame
        @test result[!, "MYQ2"] == [5.5]
    end

    @testset "MEDIAN" begin
        result =
            DBInterface.execute(
                db,
                "select count(val), MEDIAN(val) as MYMEDIAN from Numbers",
            ) |> DataFrame
        @test result[!, "MYMEDIAN"] == [5.5]
    end

    @testset "Q3" begin
        result =
            DBInterface.execute(db, "select count(val), Q3(val) as MYQ3 from Numbers") |>
            DataFrame
        @test result[!, "MYQ3"] == [7.75]
    end

    @testset "QUANTILE" begin
        result =
            DBInterface.execute(
                db,
                "select QUANTILE(val, 0.25) as MYRESULT from Numbers",
            ) |> DataFrame
        @test result[!, "MYRESULT"] == [3.25]

        result =
            DBInterface.execute(
                db,
                "select QUANTILE(val, 0.50) as MYRESULT from Numbers",
            ) |> DataFrame
        @test result[!, "MYRESULT"] == [5.5]

        result =
            DBInterface.execute(
                db,
                "select QUANTILE(val, 0.75) as MYRESULT from Numbers",
            ) |> DataFrame
        @test result[!, "MYRESULT"] == [7.75]
    end

    @testset "COV" begin
        result =
            DBInterface.execute(db, "select COV(val, val) as MYCOV from Numbers") |>
            DataFrame
        @test result[!, "MYCOV"] == [9.166666666666666]
    end

    @testset "COR" begin
        result =
            DBInterface.execute(db, "select COR(val, val) as MYCOR from Numbers") |>
            DataFrame
        @test result[!, "MYCOR"] == [1.0]

        result =
            DBInterface.execute(db, "select COR(val, otherval) as MYCOR from Numbers") |>
            DataFrame
        @test result[!, "MYCOR"] == [-1.0]
    end

    @testset "CORSPEARMAN" begin
        result =
            DBInterface.execute(db, "select CORSPEARMAN(val, val) as MYCOR from Numbers") |>
            DataFrame
        @test result[!, "MYCOR"] == [1.0]

        result =
            DBInterface.execute(
                db,
                "select CORSPEARMAN(val, otherval) as MYCOR from Numbers",
            ) |> DataFrame
        @test result[!, "MYCOR"] == [-1.0]
    end

    @testset "CORKENDALL" begin
        result =
            DBInterface.execute(db, "select CORKENDALL(val, val) as MYCOR from Numbers") |>
            DataFrame
        @test result[!, "MYCOR"] == [1.0]

        result =
            DBInterface.execute(
                db,
                "select CORKENDALL(val, otherval) as MYCOR from Numbers",
            ) |> DataFrame
        @test result[!, "MYCOR"] == [-1.0]
    end

    @testset "MAD" begin
        result =
            DBInterface.execute(db, "select MAD(val) as MYMAD from Numbers") |> DataFrame
        @test result[!, "MYMAD"] == [3.7065055462640046]
    end

    @testset "IQR" begin
        result =
            DBInterface.execute(db, "select IQR(val) as MYIQR from Numbers") |> DataFrame
        @test result[!, "MYIQR"] == [4.5]
    end

    @testset "SKEWNESS" begin
        result =
            DBInterface.execute(db, "select SKEWNESS(val) as MYSKEW from Numbers") |>
            DataFrame
        @test result[!, "MYSKEW"] == [0.0]
    end

    @testset "KURTOSIS" begin
        result =
            DBInterface.execute(db, "select KURTOSIS(val) as MYKURT from Numbers") |>
            DataFrame
        @test result[!, "MYKURT"] == [-1.2242424242424244]
    end

    @testset "GEOMEAN" begin
        result =
            DBInterface.execute(db, "select GEOMEAN(val) as MYGEOMEAN from Numbers") |>
            DataFrame
        @test result[!, "MYGEOMEAN"] == [4.528728688116766]
    end

    @testset "HARMMEAN" begin
        result =
            DBInterface.execute(db, "select HARMMEAN(val) as MYHARMMEAN from Numbers") |>
            DataFrame
        @test result[!, "MYHARMMEAN"] == [3.414171521474055]
    end

    @testset "MODE" begin
        result = DBInterface.execute(db, "select MODE(val) as m from Numbers") |> DataFrame
        @test result[!, "m"] == [1.0]

        result =
            DBInterface.execute(db, "select MODE(otherval) as m from Numbers") |> DataFrame
        @test result[!, "m"] == [10.0]
    end

    @testset "MAXAD" begin
        result =
            DBInterface.execute(db, "select MAXAD(val, val) as m from Numbers") |> DataFrame
        @test result[!, "m"] == [0.0]

        result =
            DBInterface.execute(db, "select MAXAD(val, otherval) as m from Numbers") |>
            DataFrame
        @test result[!, "m"] == [9.0]
    end

    @testset "MEANAD" begin
        result =
            DBInterface.execute(db, "select MEANAD(val, val) as m from Numbers") |>
            DataFrame
        @test result[!, "m"] == [0.0]

        result =
            DBInterface.execute(db, "select MEANAD(val, otherval) as m from Numbers") |>
            DataFrame
        @test result[!, "m"] == [5.0]
    end

    @testset "MSD" begin
        result =
            DBInterface.execute(db, "select MSD(val, val) as m from Numbers") |> DataFrame
        @test result[!, "m"] == [0.0]

        result =
            DBInterface.execute(db, "select MSD(val, otherval) as m from Numbers") |>
            DataFrame
        @test result[!, "m"] == [33.0]
    end

    SQLite.close(db)
end


@testset "Weighted Functions" begin
    db = SQLite.DB()

    SQLite.execute(db, "create table Numbers (val float, w float)")
    x = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    w = [
        0.01818181818181818,
        0.03636363636363636,
        0.05454545454545454,
        0.07272727272727272,
        0.09090909090909091,
        0.10909090909090909,
        0.12727272727272726,
        0.14545454545454545,
        0.16363636363636364,
        0.18181818181818182,
    ]
    for i = 1:10
        v = x[i]
        y = w[i]
        SQLite.execute(db, "insert into Numbers (val, w) values ($(v), $(y))")
    end

    result = DBInterface.execute(db, "select val, w from Numbers") |> DataFrame

    Sqlite3Stats.register_functions(db)

    result = DBInterface.execute(db, "select val, w from Numbers") |> DataFrame
    @test size(result) == (10, 2)

    @testset "WMEAN" begin
        result =
            DBInterface.execute(db, "select WMEAN(val, w) as MYRESULT from Numbers") |>
            DataFrame
        @test result[!, "MYRESULT"] == [7.0]
    end

    @testset "WMEDIAN" begin
        result =
            DBInterface.execute(db, "select WMEDIAN(val, w) as MYRESULT from Numbers") |>
            DataFrame
        @test result[!, "MYRESULT"] == [7.0]
    end

    @testset "ENTROPY" begin
        result =
            DBInterface.execute(db, "select ENTROPY(w) as MYRESULT from Numbers") |>
            DataFrame
        @test result[!, "MYRESULT"] == [2.151281720651836]
    end

    SQLite.close(db)

end

@testset "Linear Regression" begin

    db = SQLite.DB()

    SQLite.execute(db, "create table Numbers (x float, y float)")
    x = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    y = 2.0 .* x
    for i = 1:10
        u = x[i]
        v = y[i]
        SQLite.execute(db, "insert into Numbers (x, y) values ($(u), $(v))")
    end

    Sqlite3Stats.register_functions(db)

    @testset "Raw function" begin
        x = [1.0, 2.0, 3.0, 4.0, 5.0]
        y = [2.0, 4.0, 6.0, 8.0, 10.0]
        reg = Sqlite3Stats.linear_regression(x, y)
        @test reg[1] == 0.0
        @test reg[2] == 2.0
    end

    @testset "LINSLOPE" begin
        result =
            DBInterface.execute(db, "select LINSLOPE(x, y) as MYRESULT from Numbers") |>
            DataFrame
        @test result[!, "MYRESULT"] == [2.0]
    end

    @testset "LININTERCEPT" begin
        result =
            DBInterface.execute(db, "select LININTERCEPT(x, y) as MYRESULT from Numbers") |>
            DataFrame
        @test result[!, "MYRESULT"] == [0.0]
    end

    SQLite.close(db)
end



@testset "Normal Distribution" begin

    tol = 0.001

    db = SQLite.DB()

    Sqlite3Stats.register_functions(db)

    SQLite.execute(db, "create table numbers (NUM1 float, NUM2 float)")
    for i = 1:10
        a = rand()
        b = rand() * 10
        SQLite.execute(db, "insert into numbers(num1, num2) values ($a, $b)")
    end

    @testset "QNORM" begin
        result =
            DBInterface.execute(
                db,
                "select QNORM(0.025, 0, 1) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"], [-1.95996], atol = tol)
    end

    @testset "PNORM" begin
        result =
            DBInterface.execute(
                db,
                "select PNORM(1.9599639845400576, 0, 1) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"], [0.0584451], atol = tol)
    end

    @testset "RNORM" begin
        result =
            DBInterface.execute(
                db,
                "select RNORM(0, 1) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test result[!, "MYRESULT"][1] < 10.0
        @test result[!, "MYRESULT"][1] > -10.0
    end

    @testset "RNORM" begin
        result =
            DBInterface.execute(
                db,
                "select RNORM(10, 1) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test result[!, "MYRESULT"][1] < 30.0
        @test result[!, "MYRESULT"][1] > -10.0
    end

    SQLite.close(db)

end



@testset "T Distribution" begin

    tol = 0.001

    db = SQLite.DB()

    Sqlite3Stats.register_functions(db)

    SQLite.execute(db, "create table numbers (NUM1 float, NUM2 float)")
    for i = 1:10
        a = rand()
        b = rand() * 10
        SQLite.execute(db, "insert into numbers(num1, num2) values ($a, $b)")
    end

    @testset "PT" begin
        result =
            DBInterface.execute(
                db,
                "select PT(1.9599639845400576,30) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"][1], 0.970326, atol = tol)
    end

    @testset "QT" begin
        result =
            DBInterface.execute(
                db,
                "select QT(0.025, 30) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"][1], -2.04227, atol = tol)
    end

    @testset "RT" begin
        result =
            DBInterface.execute(
                db,
                "select RT(30) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test result[!, "MYRESULT"][1] < 30.0
        @test result[!, "MYRESULT"][1] > -10.0
    end

    SQLite.close(db)
end


@testset "ChiSquare Distribution" begin

    tol = 0.001

    db = SQLite.DB()

    Sqlite3Stats.register_functions(db)

    SQLite.execute(db, "create table numbers (NUM1 float, NUM2 float)")
    for i = 1:10
        a = rand()
        b = rand() * 10
        SQLite.execute(db, "insert into numbers(num1, num2) values ($a, $b)")
    end

    @testset "PCHISQ" begin
        result =
            DBInterface.execute(
                db,
                "select PCHISQ(30, 30) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"][1], 0.534346, atol = tol)
    end

    @testset "QCHISQ" begin
        result =
            DBInterface.execute(
                db,
                "select QCHISQ(0.05, 30) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"][1], 18.4927, atol = tol)
    end

    @testset "RCHISQ" begin
        result =
            DBInterface.execute(
                db,
                "select RCHISQ(30) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test result[!, "MYRESULT"][1] < 100.0
        @test result[!, "MYRESULT"][1] >= 0.0
    end

    SQLite.close(db)
end




@testset "F Distribution" begin

    tol = 0.001

    db = SQLite.DB()

    Sqlite3Stats.register_functions(db)

    SQLite.execute(db, "create table numbers (NUM1 float, NUM2 float)")
    for i = 1:10
        a = rand()
        b = rand() * 10
        SQLite.execute(db, "insert into numbers(num1, num2) values ($a, $b)")
    end

    @testset "PF" begin
        result =
            DBInterface.execute(
                db,
                "select PF(0.1109452, 3, 5) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"][1], 0.0499999, atol = tol)
    end

    @testset "QF" begin
        result =
            DBInterface.execute(
                db,
                "select QF(0.05, 3, 5) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"][1], 0.1109452, atol = tol)
    end

    @testset "RF" begin
        result =
            DBInterface.execute(
                db,
                "select RF(3, 5) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test result[!, "MYRESULT"][1] < 100.0
        @test result[!, "MYRESULT"][1] >= 0.0
    end

    SQLite.close(db)
end


@testset "Poisson Distribution" begin

    tol = 0.001

    db = SQLite.DB()

    Sqlite3Stats.register_functions(db)

    SQLite.execute(db, "create table numbers (NUM1 float, NUM2 float)")
    for i = 1:10
        a = rand()
        b = rand() * 10
        SQLite.execute(db, "insert into numbers(num1, num2) values ($a, $b)")
    end

    @testset "PPOIS" begin
        result =
            DBInterface.execute(
                db,
                "select PPOIS(1000000, 1000000) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"][1], 0.5, atol = tol)
    end

    @testset "QPOIS" begin
        result =
            DBInterface.execute(
                db,
                "select QPOIS(0.50, 5) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"][1], 5.0, atol = tol)
    end

    @testset "RPOIS" begin
        result =
            DBInterface.execute(
                db,
                "select RPOIS(5) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test result[!, "MYRESULT"][1] < 100.0
        @test result[!, "MYRESULT"][1] >= 0.0
    end

    SQLite.close(db)
end


@testset "Binomial Distribution" begin

    tol = 0.001

    db = SQLite.DB()

    Sqlite3Stats.register_functions(db)

    SQLite.execute(db, "create table numbers (NUM1 float, NUM2 float)")
    for i = 1:10
        a = rand()
        b = rand() * 10
        SQLite.execute(db, "insert into numbers(num1, num2) values ($a, $b)")
    end

    @testset "PBINOM" begin
        result =
            DBInterface.execute(
                db,
                "select PBINOM(5, 10, 0.5) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"][1], 0.62304687, atol = tol)
    end

    @testset "QBINOM" begin
        result =
            DBInterface.execute(
                db,
                "select QBINOM(0.50, 10, 0.5) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"][1], 5.0, atol = tol)
    end

    @testset "RBINOM" begin
        result =
            DBInterface.execute(
                db,
                "select RBINOM(10, 0.5) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test result[!, "MYRESULT"][1] <= 10.0
        @test result[!, "MYRESULT"][1] >= 0.0
    end

    SQLite.close(db)
end




@testset "Uniform Distribution" begin

    tol = 0.001

    db = SQLite.DB()

    Sqlite3Stats.register_functions(db)

    SQLite.execute(db, "create table numbers (NUM1 float, NUM2 float)")
    for i = 1:10
        a = rand()
        b = rand() * 10
        SQLite.execute(db, "insert into numbers(num1, num2) values ($a, $b)")
    end

    @testset "PUNIF" begin
        result =
            DBInterface.execute(
                db,
                "select PUNIF(5, 0, 10) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"][1], 0.5, atol = tol)
    end

    @testset "QUNIF" begin
        result =
            DBInterface.execute(
                db,
                "select QUNIF(0.5, 5, 10) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"][1], 7.5, atol = tol)
    end

    @testset "RUNIF" begin
        result =
            DBInterface.execute(
                db,
                "select RUNIF(0, 10) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test result[!, "MYRESULT"][1] <= 10.0
        @test result[!, "MYRESULT"][1] >= 0.0
    end

    SQLite.close(db)
end




@testset "Exponential Distribution" begin

    tol = 0.001

    db = SQLite.DB()

    Sqlite3Stats.register_functions(db)

    SQLite.execute(db, "create table numbers (NUM1 float, NUM2 float)")
    for i = 1:10
        a = rand()
        b = rand() * 10
        SQLite.execute(db, "insert into numbers(num1, num2) values ($a, $b)")
    end

    @testset "PEXP" begin
        result =
            DBInterface.execute(
                db,
                "select PEXP(5, 10) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"][1], 0.39346934, atol = tol)
    end

    @testset "QEXP" begin
        result =
            DBInterface.execute(
                db,
                "select QEXP(0.5, 10) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test isapprox(result[!, "MYRESULT"][1], 6.93147180, atol = tol)
    end

    @testset "REXP" begin
        result =
            DBInterface.execute(
                db,
                "select REXP(10.0) as MYRESULT from numbers limit 1",
            ) |> DataFrame
        @test result[!, "MYRESULT"][1] <= 100.0
        @test result[!, "MYRESULT"][1] >= 0.0
    end

    SQLite.close(db)
end
