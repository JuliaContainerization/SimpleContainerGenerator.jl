import Pkg

const _create_dockerfile_kwargs_docstring = """
### Keyword Arguments (for all of the above methods)
- `additional_apt::Vector{String}`
- `exclude_packages_from_sysimage::Vector{String}`
- `julia_cpu_target::String`
- `julia_version::Union{String, VersionNumber}`
- `make_sysimage::Bool`
- `no_test::Vector{String}`
- `output_directory::String`. Default value: `pwd()`
- `parent_image::String`
- `tests_must_pass::Vector{String}`

### Advanced Keyword Arguments (for all of the above methods)
- `override_default_apt::Vector{String}`
- `packagecompiler_installation_command::String`
- `precompile_execution_env_vars::Dict{String, String}`
- `wrapper_script_env_vars::Dict{String, String}`
"""

"""
    create_dockerfile(config::SimpleContainerGenerator.Config;
                      output_directory = pwd())

### Arguments
- `config::SimpleContainerGenerator.Config`

### Keyword Arguments
- `output_directory::String`. Default value: `pwd()`
"""
function create_dockerfile(config::Config;
                           output_directory::AbstractString = pwd())
    template = Template(config)
    result = create_dockerfile(template;
                               output_directory = output_directory)
    return result
end

"""
    create_dockerfile(template::SimpleContainerGenerator.Template;
                      output_directory = pwd())

### Arguments
- `template::SimpleContainerGenerator.Template`

### Keyword Arguments
- `output_directory::String`. Default value: `pwd()`
"""
function create_dockerfile(template::Template;
                           output_directory::AbstractString = pwd())
    _write_all_docker_files(template;
                            output_directory = output_directory)
    @info("I have generated the Dockerfile and the other necessary files.")
    @info("Now `cd` to `$(output_directory)` and run:")
    @info("`docker build -t my_docker_username/my_image_name .`")
    return output_directory
end

"""
    create_dockerfile(pkg::Union{String, NamedTuple, Dict{Symbol, String}};
                      kwargs...)

    create_dockerfile(pkg_names::Vector{String};
                      kwargs...)

    create_dockerfile(pkg_tuples::Vector{<:NamedTuple};
                      kwargs...)

    create_dockerfile(pkgs::Vector{Dict};
                      kwargs...)

$(_create_dockerfile_kwargs_docstring)
"""
function create_dockerfile(varargs...;
                           output_directory::AbstractString = pwd(),
                           kwargs...)
    config = Config(varargs...; kwargs...)
    result = create_dockerfile(config;
                               output_directory = output_directory)
    return result
end
