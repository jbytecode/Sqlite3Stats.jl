using Documenter, SQLite3Stats

makedocs(
         format = Documenter.HTML(
                                  prettyurls = get(ENV, "CI", nothing) == "true",
                                  collapselevel = 2,
                                  # assets = ["assets/favicon.ico", "assets/extra_styles.css"],
                                  # analytics = "UA-xxxxxxxxx-x",
                                 ),
         sitename="Sqlite3Stats.jl",
         authors = "Mehmet Hakan Satman",
         pages = [
                  "Index" => "index.md",
                  "Examples" =>  "examples.md",
                  "API References" => "api.md",
                  "Contributing" => "contributing.md",
                 ]
        )


