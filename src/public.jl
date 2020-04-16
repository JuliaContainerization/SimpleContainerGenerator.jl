import Pkg

@inline function create_dockerfile(pkg::Union{AbstractDict{<:Symbol, <:AbstractString}, AbstractString, NamedTuple},
                                   output_directory::AbstractString = pwd();
                                   kwargs...)
    return create_dockerfile([pkg], output_directory; kwargs...)
end

@inline function create_dockerfile(pkg_names::AbstractVector{<:AbstractString},
                                   output_directory::AbstractString = pwd();
                                   kwargs...)
    num_pkgs = length(pkg_names)
    Dict{Symbol, String}
    pkgs = Vector{Dict{Symbol, String}}(undef, num_pkgs)
    for i = 1:num_pkgs
        pkgs[i] = Dict(:name => pkg_names[i])
    end
    return create_dockerfile(pkgs, output_directory; kwargs...)
end

@inline function create_dockerfile(pkg_tuples::AbstractVector{<:NamedTuple},
                                   output_directory::AbstractString = pwd();
                                   kwargs...)
    pkgs = Dict.(pairs.(pkg_tuples))
    return create_dockerfile(pkgs, output_directory; kwargs...)
end

@inline function create_dockerfile(pkgs::AbstractVector{<:AbstractDict},
                                   output_directory::AbstractString = pwd();
                                   kwargs...)
    config = Config(pkgs; kwargs...)
    return create_dockerfile(config, output_directory)
end

@inline function create_dockerfile(config::Config,
                                   output_directory::AbstractString = pwd())
    _write_all_docker_files(config, output_directory)
    @info("I have generated the Dockerfile and the other necessary files.")
    @info("Now `cd` to `$(output_directory)` and run:")
    @info("`docker build -t my_docker_username/my_image_name .`")
    return output_directory
end
