import Pkg

@inline function stopgap_docker(pkg::Union{AbstractDict{<:Symbol, <:AbstractString}, AbstractString, NamedTuple},
                                output_directory::AbstractString = pwd();
                                kwargs...)
    return stopgap_docker([pkg], output_directory; kwargs...)
end

@inline function stopgap_docker(pkg_names::AbstractVector{<:AbstractString},
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

@inline function stopgap_docker(pkg_tuples::AbstractVector{<:NamedTuple},
                                output_directory::AbstractString = pwd();
                                kwargs...)
    pkgs = Dict.(pairs.(pkg_tuples))
    return stopgap_docker(pkgs, output_directory; kwargs...)
end

@inline function stopgap_docker(pkgs::AbstractVector{<:AbstractDict},
                                output_directory::AbstractString = pwd();
                                kwargs...)
    config = Config(pkgs; kwargs...)
    return stopgap_docker(config, output_directory)
end

@inline function stopgap_docker(config::Config,
                                output_directory::AbstractString = pwd())
    _write_all_docker_files(config, output_directory)
    @info("I have generated the Dockerfile and the other necessary files.")
    @info("Now `cd` to `$(output_directory)` and run:")
    @info("`docker build -t my_docker_username/my_image_name .`")
    return output_directory
end
