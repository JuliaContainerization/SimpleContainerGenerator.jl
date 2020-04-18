import Pkg

@inline function _generate_packagecompiler_content(config::Config)
    packagecompiler_installation_command = config.packagecompiler_installation_command
    julia_cpu_target = config.julia_cpu_target
    make_sysimage = config.make_sysimage
    exclude_packages_from_sysimage = config.exclude_packages_from_sysimage
    return string("import Pkg\n",
                  "stdlib_uuids = collect(keys(Pkg.Types.stdlibs()))\n",
                  "pkgnames = Vector{String}(undef, 0)\n",
                  "for (uuid, info) in Pkg.dependencies()\n",
                  "if !(info.name in $(exclude_packages_from_sysimage))\n",
                  "push!(pkgnames, info.name)\n",
                  "end\n",
                  "end\n",
                  "pkgnames_symbols = Symbol.(pkgnames)\n",
                  "println(\"pkgnames_symbols: (n = \$(length(pkgnames_symbols)))\")\n",
                  "for i = 1:length(pkgnames_symbols)\n",
                  "println(\"\$(i). \$(pkgnames_symbols[i])\")\n",
                  "end\n",
                  "Pkg.pkg\"$(packagecompiler_installation_command)\"\n",
                  "import PackageCompiler\n",
                  "if $(make_sysimage)\n",
                  "PackageCompiler.create_sysimage(",
                  "pkgnames_symbols; ",
                  "cpu_target = \"$(julia_cpu_target)\", ",
                  "precompile_execution_file=\"/opt/simplecontainergenerator_containers/precompile.jl\", ",
                  "sysimage_path = \"/opt/simplecontainergenerator_containers/sysimage/SimpleContainerGeneratorSysimage.so\"",
                  ")\n",
                  "end\n")
end
