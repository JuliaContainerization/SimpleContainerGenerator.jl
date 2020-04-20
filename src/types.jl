struct AlwaysAssertionError <: Exception
    msg::String
end

struct Config
    apt::Vector{String}
    exclude_packages_from_sysimage::Vector{String}
    julia_cpu_target::String
    julia_version::Union{String, VersionNumber}
    make_sysimage::Bool
    no_test::Vector{String}
    packagecompiler_installation_command::String
    parent_image::String
    pkgs::Vector{Dict{Symbol,String}}
    precompile_execution_env_vars::Dict{String, String}
    simplecontainergenerator_installation_command::String
    wrapper_script_env_vars::Dict{String, String}
end

@inline function Config(pkgs::AbstractVector{<:AbstractDict{<:Symbol,<:AbstractString}} =
                            Vector{Dict{Symbol,String}}(undef, 0);
                        #
                        additional_apt::AbstractVector{<:AbstractString} =
                            String[],
                        override_default_apt::AbstractVector{<:AbstractString} =
                            _default_apt(),
                        #
                        exclude_packages_from_sysimage =
                            String[],
                        julia_cpu_target =
                            _default_julia_cpu_target(),
                        julia_version::Union{AbstractString, VersionNumber} =
                            _default_julia_version(),
                        make_sysimage::Bool =
                            true,
                        no_test =
                            String[],
                        packagecompiler_installation_command::String =
                            _default_packagecompiler_installation_command(),
                        parent_image::String = _default_docker_parent_image(),
                        precompile_execution_env_vars =
                            _default_precompile_execution_env_vars(),
                        simplecontainergenerator_installation_command::String =
                            _default_simplecontainergenerator_installation_command(),
                        wrapper_script_env_vars =
                            _default_wrapper_script_env_vars())
    apt = Vector{String}(undef, 0)
    append!(apt, override_default_apt)
    append!(apt, additional_apt)
    unique!(apt)
    config = Config(apt,
                    exclude_packages_from_sysimage,
                    julia_cpu_target,
                    julia_version,
                    make_sysimage,
                    no_test,
                    packagecompiler_installation_command,
                    parent_image,
                    pkgs,
                    precompile_execution_env_vars,
                    simplecontainergenerator_installation_command,
                    wrapper_script_env_vars)
    return config
end
