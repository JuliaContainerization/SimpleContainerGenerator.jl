using Pkg
using StopgapContainers
using Test

@testset "StopgapContainers.jl" begin
    @testset "public.jl" begin
        StopgapContainers.with_temp_dir() do tmp_dir
            @test !isfile("Dockerfile")
            stopgap_docker("Crayons")
            @test isfile("Dockerfile")
        end
        StopgapContainers.with_temp_dir() do tmp_dir
            @test !isfile("Dockerfile")
            stopgap_docker(["Crayons"])
            @test isfile("Dockerfile")
        end
        StopgapContainers.with_temp_dir() do tmp_dir
            @test !isfile("Dockerfile")
            stopgap_docker(Pkg.PackageSpec(name = "Crayons"))
            @test isfile("Dockerfile")
        end
        StopgapContainers.with_temp_dir() do tmp_dir
            @test !isfile("Dockerfile")
            stopgap_docker([Pkg.PackageSpec(name = "Crayons")])
            @test isfile("Dockerfile")
        end
    end
    @testset "docker.jl" begin
        @test StopgapContainers._generate_apt_install_command(StopgapContainers.Config(; apt = String[])) == ""
    end
    @testset "julia.jl" begin
        @test StopgapContainers._get_julia_url("nightly") == "https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz"
        @test StopgapContainers._get_julia_url("1.3") == "https://julialang-s3.julialang.org/bin/linux/x64/1.3/julia-1.3-latest-linux-x86_64.tar.gz"
    end
end
