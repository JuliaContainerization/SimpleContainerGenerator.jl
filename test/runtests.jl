using StopgapContainers
using Test

import Pkg
import Random: randstring

@testset "StopgapContainers.jl" begin
    @testset "public.jl" begin
        test_cases = ["Crayons",
                      ["Crayons"],
                      (name = "Crayons",),
                      [(name = "Crayons",)],
                      Dict(:name => "Crayons"),
                      [Dict(:name => "Crayons")]]
        for test_case in test_cases
            StopgapContainers.with_temp_dir() do tmp_dir
                @test !isfile("Dockerfile")
                stopgap_docker(test_case)
                @test isfile("Dockerfile")
            end
        end
    end
    @testset "docker.jl" begin
        @test StopgapContainers._generate_apt_install_command(StopgapContainers.Config(; default_apt = String[])) == ""
    end
    @testset "julia.jl" begin
        @test StopgapContainers._get_julia_url("nightly") == "https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz"
        @test StopgapContainers._get_julia_url("1.3") == "https://julialang-s3.julialang.org/bin/linux/x64/1.3/julia-1.3-latest-linux-x86_64.tar.gz"
    end
    if get(ENV, "STOPGAP_CONTAINERS_TESTS", "") == "all"
        @testset "docker build" begin
            test_cases = ["Crayons" => "using Crayons"]
            for (pkgs, test_eval_expr) in test_cases
                StopgapContainers.with_temp_dir() do tmp_dir
                    @test !isfile("Dockerfile")
                    stopgap_docker(pkgs)
                    @test isfile("Dockerfile")
                    image = lowercase("test_stopgapcontainers_$(randstring(16))")
                    p1 = run(`docker build -t $(image) .`)
                    wait(p1)
                    @test success(p1)
                    p2 = run(`docker run $(image) "/usr/bin/stopgap_julia -e '$(test_eval_expr)'"`)
                    wait(p2)
                    @test success(p2)
                end
            end
        end
    end
end
