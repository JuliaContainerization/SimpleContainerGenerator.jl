import Pkg

function stopgap_docker(pkg::Union{AbstractDict{<:Symbol, <:AbstractString}, AbstractString, NamedTuple},
                        output_directory::AbstractString = pwd();
                        kwargs...)
    return stopgap_docker([pkg], output_directory; kwargs...)
end

function stopgap_docker(pkg_names::AbstractVector{<:AbstractString},
                        output_directory::AbstractString = pwd();
                        kwargs...)
    num_pkgs = length(pkg_names)
    Dict{Symbol, String}
    pkgs = Vector{Dict{Symbol, String}}(undef, num_pkgs)
    for i = 1:num_pkgs
        pkgs[i] = Dict(:name => pkg_names[i])
    end
    return stopgap_docker(pkgs, output_directory; kwargs...)
end

function stopgap_docker(pkg_tuples::AbstractVector{<:NamedTuple},
                        output_directory::AbstractString = pwd();
                        kwargs...)
    pkgs = Dict.(pairs.(pkg_tuples))
    println(typeof(pkgs))
    return stopgap_docker(pkgs, output_directory; kwargs...)
end

function stopgap_docker(pkgs::AbstractVector{<:AbstractDict},
                        output_directory::AbstractString = pwd();
                        kwargs...)
    config = Config(pkgs; kwargs...)
    return stopgap_docker(config, output_directory; kwargs...)
end

function stopgap_docker(config::Config,
                        output_directory::AbstractString = pwd())
    _write_all_docker_files(config, output_directory)
    @info("I have generated the Dockerfile and the other necessary files.")
    @info("Now `cd` to `$(output_directory)` and run:")
    @info("`docker build -t my_docker_image .`")
    @info("After you have build your Docker image, you can enter it by running:")
    # @info("`docker run --name my_docker_container -it my_docker_image /bin/bash`")
    @info("`docker run --name my_docker_container -it my_docker_image`")
    return config
end
