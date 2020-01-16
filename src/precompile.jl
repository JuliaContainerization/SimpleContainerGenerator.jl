function _generate_precompile_content(config::Config)
    pkgs = config.pkgs
    no_test = config.no_test
    pkg_names_to_test = Vector{String}(undef, 0)
    for pkg in pkgs
        pkg_name = pkg[:name]
        if !(pkg_name in no_test)
            push!(pkg_names_to_test, pkg_name)
        end
    end
    return string("import Pkg\n",
                  "for (uuid, info) in Pkg.dependencies()\n",
                  "if info.name in $(pkg_names_to_test)\n",
                  "include(joinpath(info.source, \"test\", \"runtests.jl\"))\n",
                  "end\n",
                  "end\n")
end
