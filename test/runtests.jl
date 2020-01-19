using SimpleContainerGenerator
using Test

import Pkg
import Random: randstring

@testset "SimpleContainerGenerator.jl" begin
    @testset "public.jl" begin
        test_cases = ["Crayons",
                      ["Crayons"],
                      (name = "Crayons",),
                      [(name = "Crayons",)],
                      Dict(:name => "Crayons"),
                      [Dict(:name => "Crayons")]]
        for test_case in test_cases
            SimpleContainerGenerator.with_temp_dir() do tmp_dir
                @test !isfile("Dockerfile")
                stopgap_docker(test_case)
                @test isfile("Dockerfile")
            end
        end
    end
    @testset "docker.jl" begin
        @test SimpleContainerGenerator._generate_apt_install_command(SimpleContainerGenerator.Config(; default_apt = String[])) == ""
    end
    @testset "julia.jl" begin
        @test SimpleContainerGenerator._get_julia_url("nightly") == "https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz"
        @test SimpleContainerGenerator._get_julia_url("1.3") == "https://julialang-s3.julialang.org/bin/linux/x64/1.3/julia-1.3-latest-linux-x86_64.tar.gz"
    end
    if get(ENV, "STOPGAPCONTAINERS_TESTS", "") == "all"
        @testset "docker build" begin
            test_cases = [[Dict(:name => "Crayons")] => ["import Crayons", "using Crayons", "import Pkg; Pkg.test(string(:Crayons))"]]
            for (pkgs, test_eval_exprs) in test_cases
                SimpleContainerGenerator.with_temp_dir() do tmp_dir
                    @test !isfile("Dockerfile")
                    stopgap_docker(pkgs)
                    @test isfile("Dockerfile")
                    image = lowercase("test_stopgapcontainers_$(randstring(16))")
                    p_build = run(`docker build -t $(image) .`)
                    wait(p_build)
                    @test success(p_build)
                    for test_eval_expr in test_eval_exprs
                        p_test = run(`docker run $(image) "/usr/bin/stopgap_julia -e '$(test_eval_expr)'"`)
                        wait(p_test)
                        @test success(p_test)
                    end
                end
            end
        end
    end
end
