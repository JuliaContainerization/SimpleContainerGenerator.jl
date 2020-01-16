import Pkg

function _to_string(pkg::Pkg.Types.PackageSpec)
    kwargs_string = ""
    for field in [:name, :path, :repo, :uuid, :version]
        value = getproperty(pkg, field)
        if value != nothing && value != Pkg.Types.GitRepo(nothing, nothing) && value != Pkg.Types.VersionSpec("*")
            kwargs_string *= "$(field) = $(repr(value)), "
        end
    end
    return "Pkg.PackageSpec(; $(kwargs_string))"
end

function _to_string(pkgs::AbstractVector{<:Pkg.Types.PackageSpec})
    num_pkgs = length(pkgs)
    pkg_strings = Vector{String}(undef, num_pkgs)
    for i = 1:num_pkgs
        pkg_strings[i] = _to_string(pkgs[i])
    end
    return "Pkg.Types.PackageSpec[$(join(pkg_strings, ", "))]"
end

function _generate_install_packages_content(config::Config)
    pkgs = config.pkgs
    pkgs_string = _to_string(pkgs)
    return string("import Pkg\n",
                  "const VersionSpec = Pkg.Types.VersionSpec\n",
                  "pkgs = $(pkgs_string)\n",
                  "Pkg.add(pkgs)\n",
                  "deps = Pkg.dependencies()\n",
                  "for (uuid, info) in deps\n",
                  "Pkg.add(info.name)\n",
                  "end\n")
end
