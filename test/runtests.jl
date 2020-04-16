using SimpleContainerGenerator
using Test

import Pkg
import Random: randstring

@testset "SimpleContainerGenerator.jl" begin
    @testset "assert.jl" begin
        Test.@test SimpleContainerGenerator.always_assert(true, "") == nothing
        Test.@test_throws SimpleContainerGenerator.AlwaysAssertionError SimpleContainerGenerator.always_assert(false, "")
    end

    @testset "default_values.jl" begin
        Test.@test SimpleContainerGenerator._default_julia_cpu_target() isa AbstractString
        Test.@test SimpleContainerGenerator._recommended_julia_cpu_target() isa AbstractString
        Test.@test SimpleContainerGenerator._fastest_nonportable_julia_cpu_target() isa AbstractString
        Test.@test SimpleContainerGenerator._predictmd_apt() isa AbstractVector
    end

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
                SimpleContainerGenerator.create_dockerfile(test_case)
                @test isfile("Dockerfile")
            end
            for make_sysimage in [true, false]
                SimpleContainerGenerator.with_temp_dir() do tmp_dir
                    @test !isfile("Dockerfile")
                    SimpleContainerGenerator.create_dockerfile(test_case; make_sysimage = make_sysimage)
                    @test isfile("Dockerfile")
                end
            end
        end
    end

    @testset "docker.jl" begin
        @test SimpleContainerGenerator._generate_apt_install_command(SimpleContainerGenerator.Config(; default_apt = String[])) == ""
    end

    @testset "julia.jl" begin
        @test SimpleContainerGenerator._get_julia_url("nightly") == ("https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz", "https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz.asc")
        @test SimpleContainerGenerator._get_julia_url("1.4.1") == ("https://julialang-s3.julialang.org/bin/linux/x64/1.4/julia-1.4.1-linux-x86_64.tar.gz", "https://julialang-s3.julialang.org/bin/linux/x64/1.4/julia-1.4.1-linux-x86_64.tar.gz.asc")
    end

    if get(ENV, "SIMPLECONTAINERGENERATOR_TESTS", "") == "all"
        @testset "docker build" begin
            test_cases = [([Dict(:name => "Example")], ["import Example", "using Example", "import Pkg; Pkg.test(string(:Example))"])]
            for (pkgs, test_eval_exprs) in test_cases
                for make_sysimage in [true, false]
                    SimpleContainerGenerator.with_temp_dir() do tmp_dir
                        @test !isfile("Dockerfile")
                        SimpleContainerGenerator.create_dockerfile(pkgs; make_sysimage = make_sysimage)
                        @test isfile("Dockerfile")
                        image = lowercase("test_simplecontainergenerator_runtests_$(randstring(16))")
                        p_build = run(`docker build -t $(image) .`)
                        wait(p_build)
                        @test success(p_build)
                        for test_eval_expr in test_eval_exprs
                            p_test = run(`docker run $(image) "/usr/bin/julia -e '$(test_eval_expr)'"`)
                            wait(p_test)
                            @test success(p_test)
                        end
                    end
                end
            end
        end
    end
end
