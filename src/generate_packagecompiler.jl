import Pkg

function _generate_packagecompiler_content(config::Config)
    packagecompilerx_installation_command = config.packagecompilerx_installation_command
    julia_cpu_target = config.julia_cpu_target
    return string("import Pkg\n",
                  "stdlib_uuids = collect(keys(Pkg.Types.stdlib()))\n",
                  "pkgnames = Vector{String}(undef, 0)\n",
                  "for (uuid, info) in Pkg.dependencies()\n",
                  # "if !(uuid in stdlib_uuids)\n",
                  "if true\n",
                  "push!(pkgnames, info.name)\n",
                  "end\n",
                  "end\n",
                  "pkgnames_symbols = Symbol.(pkgnames)\n",
                  "Pkg.pkg\"$(packagecompilerx_installation_command)\"\n",
                  "import PackageCompilerX\n",
                  "PackageCompilerX.create_sysimage(",
                  "pkgnames_symbols; ",
                  "cpu_target = \"$(julia_cpu_target)\", ",
                  "precompile_execution_file=\"/opt/stopgapcontainers/precompile.jl\", ",
                  "sysimage_path = \"/opt/stopgapcontainers/sysimage/SimpleContainerGeneratorSysimage.so\"",
                  ")")
end
