struct AlwaysAssertionError <: Exception
    msg::String
end

struct Config
    julia_version::Union{String, VersionNumber}
    apt::Vector{String}
    pkgs::Vector{Dict{Symbol,String}}
    no_test::Vector{String}
    exclude_packages_from_sysimage::Vector{String}
    packagecompiler_installation_command::String
    precompile_env_vars::Dict{String, String}
    julia_cpu_target::String
    wrapper_script_env_vars::Dict{String, String}
    make_sysimage::Bool
end
