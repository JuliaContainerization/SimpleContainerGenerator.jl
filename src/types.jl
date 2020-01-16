struct Config
    julia_version::String
    apt::Vector{String}
    pkgs::Vector{Pkg.Types.PackageSpec}
    notest::Vector{String}
    packagecompilerx_installation_command::String
end

function Config(pkgs::AbstractVector{<:Pkg.Types.PackageSpec} = Pkg.Types.PackageSpec[];
                notest = String[],
                julia_version::AbstractString = _default_julia_version,
                apt::AbstractVector{<:AbstractString} = _default_apt,
                packagecompilerx_installation_command::String = _default_packagecompilerx_installation_command)
    return Config(julia_version,
                  apt,
                  pkgs,
                  notest,
                  packagecompilerx_installation_command)
end
