import Pkg

const _create_dockerfile_kwargs_docstring = """
### Keyword Arguments
- `additional_apt::Vector{String}`
- `exclude_packages_from_sysimage::Vector{String}`
- `julia_cpu_target::String`
- `julia_version::Union{String, VersionNumber}`
- `make_sysimage::Bool`
- `no_test::Vector{String}`
- `parent_image::String`

### Advanced Keyword Arguments
- `override_default_apt::Vector{String}`
- `packagecompiler_installation_command::String`
- `precompile_execution_env_vars::Dict{String, String}`
- `wrapper_script_env_vars::Dict{String, String}`
"""

"""
    create_dockerfile(pkg, output_directory = pwd(); kwargs...)

### Arguments
- `pkg::Union{String, NamedTuple, Dict{Symbol, String}}`
- `output_directory::String`. Default value: `pwd()`

$(_create_dockerfile_kwargs_docstring)
"""
@inline function create_dockerfile(pkg::Union{AbstractDict{<:Symbol, <:AbstractString}, AbstractString, NamedTuple},
                                   output_directory::AbstractString = pwd();
                                   kwargs...)
    return create_dockerfile([pkg], output_directory; kwargs...)
end

"""
    create_dockerfile(pkg_names, output_directory = pwd(); kwargs...)

### Arguments
- `pkg_names::Vector{String}`
- `output_directory::String`. Default value: `pwd()`

$(_create_dockerfile_kwargs_docstring)
"""
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

"""
    create_dockerfile(pkg_tuples, output_directory = pwd(); kwargs...)

### Arguments
- `pkg_tuples::Vector{<:NamedTuple}`
- `output_directory::String`. Default value: `pwd()`

$(_create_dockerfile_kwargs_docstring)
"""
@inline function create_dockerfile(pkg_tuples::AbstractVector{<:NamedTuple},
                                   output_directory::AbstractString = pwd();
                                   kwargs...)
    pkgs = Dict.(pairs.(pkg_tuples))
    return create_dockerfile(pkgs, output_directory; kwargs...)
end

"""
    create_dockerfile(pkgs, output_directory = pwd(); kwargs...)

### Arguments
- `pkgs::Vector{Dict}`
- `output_directory::String`. Default value: `pwd()`

$(_create_dockerfile_kwargs_docstring)
"""
@inline function create_dockerfile(pkgs::AbstractVector{<:AbstractDict},
                                   output_directory::AbstractString = pwd();
                                   kwargs...)
    config = Config(pkgs; kwargs...)
    return create_dockerfile(config, output_directory)
end

"""
    create_dockerfile(config::SimpleContainerGenerator.Config, output_directory::AbstractString = pwd())

### Arguments
- `config::SimpleContainerGenerator.Config`
- `output_directory::String`. Default value: `pwd()`

$(_create_dockerfile_kwargs_docstring)
"""
@inline function create_dockerfile(config::Config,
                                   output_directory::AbstractString = pwd())
    _write_all_docker_files(config, output_directory)
    @info("I have generated the Dockerfile and the other necessary files.")
    @info("Now `cd` to `$(output_directory)` and run:")
    @info("`docker build -t my_docker_username/my_image_name .`")
    return output_directory
end
