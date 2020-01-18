struct Config
    julia_version::String
    apt::Vector{String}
    pkgs::Vector{Dict{Symbol,String}}
    no_test::Vector{String}
    packagecompilerx_installation_command::String
    precompile_env_vars::Dict{String, String}
end

function Config(pkgs::AbstractVector{<:AbstractDict{<:Symbol,<:AbstractString}} =
                    Vector{Dict{Symbol,String}}(undef, 0);
                no_test =
                    String[],
                julia_version::AbstractString =
                    _default_julia_version,
                default_apt::AbstractVector{<:AbstractString} =
                    _default_apt,
                additional_apt::AbstractVector{<:AbstractString} =
                    String[],
                packagecompilerx_installation_command::String =
                    _default_packagecompilerx_installation_command,
                precompile_env_vars =
                    _default_precompile_env_vars)
    apt = Vector{String}(undef, 0)
    append!(apt, default_apt)
    append!(apt, additional_apt)
    unique!(apt)
    return Config(julia_version,
                  apt,
                  pkgs,
                  no_test,
                  packagecompilerx_installation_command)
end
