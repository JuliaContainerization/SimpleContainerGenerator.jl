import Pkg

function _to_packagespec_string(pkg::Dict{Symbol, String})
    kwargs_string = ""
    for (key, value) in pkg
        kwargs_string *= "$(key) = \"$(value)\", "
    end
    return "Pkg.PackageSpec(; $(kwargs_string))"
end

function _to_packagespec_string(pkgs::AbstractVector{<:AbstractDict})
    num_pkgs = length(pkgs)
    pkg_strings = Vector{String}(undef, num_pkgs)
    for i = 1:num_pkgs
        pkg_strings[i] = _to_packagespec_string(pkgs[i])
    end
    return "Pkg.Types.PackageSpec[$(join(pkg_strings, ", "))]"
end

function _generate_install_packages_content(config::Config)
    pkgs = config.pkgs
    pkgs_string = _to_packagespec_string(pkgs)
    return string("import Pkg\n",
                  "Pkg.add($(pkgs_string))\n",
                  "for (uuid, info) in Pkg.dependencies()\n",
                  "Pkg.add(info.name)\n",
                  "end\n")
end
