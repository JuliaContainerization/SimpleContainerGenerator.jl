function _generate_precompile_content(config::Config)
    pkgs = config.pkgs
    notest = config.notest
    pkg_names_to_test = Vector{String}(undef, 0)
    for pkg in pkgs
        pkg_name = pkg.name
        if !(pkg_name in notest)
            push!(pkg_names_to_test, pkg_name)
        end
    end
    return string("import Pkg\n",
                  "pkg_names_to_test = $(pkg_names_to_test)\n",
                  "deps = Pkg.dependencies()\n",
                  "for (uuid, info) in deps\n",
                  "if info.name in pkg_names_to_test\n",
                  "include(joinpath(info.source, \"test\", \"runtests.jl\"))\n",
                  "end\n",
                  "end\n")
end
