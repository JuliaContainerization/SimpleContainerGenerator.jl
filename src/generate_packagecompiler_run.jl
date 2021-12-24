import Pkg

function _generate_packagecompiler_run_content(config::Config)
    julia_cpu_target = config.julia_cpu_target
    make_sysimage = config.make_sysimage
    exclude_packages_from_sysimage = config.exclude_packages_from_sysimage
    lines = String[
        "import Pkg",

        "all_stdlib_uuids = collect(keys(Pkg.Types.stdlibs()))",
        "if Base.VERSION >= v\"1.8-\"",
        "all_stdlib_names = first.(collect(values(Pkg.Types.stdlibs())))",
        "else",
        "all_stdlib_names = collect(values(Pkg.Types.stdlibs()))",
        "end",

        "pkgnames = Vector{String}(undef, 0)",
        "for (uuid, info) in Pkg.dependencies()",
        "    if !(info.name in $(exclude_packages_from_sysimage))",
        "        push!(pkgnames, info.name)",
        "    end",
        "end",
        "sort!(pkgnames)",

        "pkgnames_nonstdlib = Vector{String}(undef, 0)",
        "pkgnames_stdlib = Vector{String}(undef, 0)",
        "for name in pkgnames",
        "    if name in all_stdlib_names",
        "        push!(pkgnames_stdlib, name)",
        "    else",
        "        push!(pkgnames_nonstdlib, name)",
        "    end",
        "end",

        "pkgnames_symbols = Symbol.(pkgnames)",
        "pkgnames_nonstdlib_symbols = Symbol.(pkgnames_nonstdlib)",
        "pkgnames_stdlib_symbols = Symbol.(pkgnames_stdlib)",
        "println(\"The length of pkgnames_symbols is \$(length(pkgnames_symbols))\")",
        "println(\"The length of pkgnames_nonstdlib_symbols is \$(length(pkgnames_nonstdlib_symbols))\")",
        "println(\"The length of pkgnames_stdlib_symbols is \$(length(pkgnames_stdlib_symbols))\")",

        "println(\"pkgnames_symbols: (n = \$(length(pkgnames_symbols)))\")",
        "for i = 1:length(pkgnames_symbols)",
        "    println(\"\$(i). \$(pkgnames_symbols[i])\")",
        "end",

        "println(\"pkgnames_nonstdlib_symbols: (n = \$(length(pkgnames_nonstdlib_symbols)))\")",
        "for i = 1:length(pkgnames_nonstdlib_symbols)",
        "    println(\"\$(i). \$(pkgnames_nonstdlib_symbols[i])\")",
        "end",

        "println(\"pkgnames_stdlib_symbols: (n = \$(length(pkgnames_stdlib_symbols)))\")",
        "for i = 1:length(pkgnames_stdlib_symbols)",
        "    println(\"\$(i). \$(pkgnames_stdlib_symbols[i])\")",
        "end",

        "_simplecontainergenerator_containers_temp_depot_tmpdir_import_packagecompiler = mktempdir()",
        "atexit(() -> rm(_simplecontainergenerator_containers_temp_depot_tmpdir_import_packagecompiler; force = true, recursive = true))",
        "pushfirst!(Base.DEPOT_PATH, \"/opt/simplecontainergenerator_containers/packagecompiler_depot\")",
        "pushfirst!(Base.DEPOT_PATH, _simplecontainergenerator_containers_temp_depot_tmpdir_import_packagecompiler)",
        "import PackageCompiler",
        "popfirst!(Base.DEPOT_PATH)",
        "popfirst!(Base.DEPOT_PATH)",

        "make_sysimage = $(make_sysimage)",
        "if make_sysimage",
        "    PackageCompiler.create_sysimage(",
        "        pkgnames_symbols; ",
        "        cpu_target = \"$(julia_cpu_target)\", ",
        "        precompile_execution_file = \"/opt/simplecontainergenerator_containers/precompile_execution.jl\", ",
        "        project = \"/opt/simplecontainergenerator_containers/julia_project\", ",
        "        sysimage_path = \"/opt/simplecontainergenerator_containers/sysimage/SimpleContainerGeneratorSysimage.so\"",
        "        )",
        "end",
    ]
    content = join(lines, "\n") * "\n"
    return content
end
