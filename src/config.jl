@inline function Config(pkgs::AbstractVector{<:AbstractDict{<:Symbol,<:AbstractString}} =
                            Vector{Dict{Symbol,String}}(undef, 0);
                        no_test =
                            String[],
                        exclude_packages_from_sysimage =
                            String[],
                        julia_version::Union{AbstractString, VersionNumber} =
                            _default_julia_version(),
                        default_apt::AbstractVector{<:AbstractString} =
                            _default_apt(),
                        additional_apt::AbstractVector{<:AbstractString} =
                            String[],
                        packagecompiler_installation_command::String =
                            _default_packagecompiler_installation_command(),
                        precompile_env_vars =
                            _default_precompile_env_vars(),
                        julia_cpu_target =
                            _default_julia_cpu_target(),
                        wrapper_script_env_vars =
                            _default_wrapper_script_env_vars(),
                        make_sysimage::Bool =
                            true)
    apt = Vector{String}(undef, 0)
    append!(apt, default_apt)
    append!(apt, additional_apt)
    unique!(apt)
    return Config(julia_version,
                  apt,
                  pkgs,
                  no_test,
                  exclude_packages_from_sysimage,
                  packagecompiler_installation_command,
                  precompile_env_vars,
                  julia_cpu_target,
                  wrapper_script_env_vars,
                  make_sysimage)
end
