import Pkg

@inline function _to_packagespec_string(pkg::Dict{Symbol, String})
    kwargs_string = ""
    for (key, value) in pkg
        kwargs_string *= "$(key) = \"$(value)\", "
    end
    return "Pkg.PackageSpec(; $(kwargs_string))"
end

@inline function _to_packagespec_string(pkgs::AbstractVector{<:AbstractDict})
    num_pkgs = length(pkgs)
    pkg_strings = Vector{String}(undef, num_pkgs)
    for i = 1:num_pkgs
        pkg_strings[i] = _to_packagespec_string(pkgs[i])
    end
    return "Pkg.Types.PackageSpec[$(join(pkg_strings, ", "))]"
end

@inline function _generate_install_packages_content(config::Config)
    pkgs = config.pkgs
    no_test = config.no_test
    exclude_packages_from_sysimage = config.exclude_packages_from_sysimage
    pkg_names_to_import = Vector{String}(undef, 0)
    pkg_names_to_test = Vector{String}(undef, 0)
    for pkg in pkgs
        pkg_name = pkg[:name]
        if ( !(pkg_name in no_test) ) && ( !(pkg_name in exclude_packages_from_sysimage) )
            push!(pkg_names_to_test, pkg_name)
        end
    end
    pkgs_string = _to_packagespec_string(pkgs)
    lines = String[
        "import Pkg",
        "Pkg.add($(pkgs_string))",
        "for name in $(pkg_names_to_test) # pkg_names_to_test",
        "Pkg.add(name)",
        "Pkg.test(name)",
        "end",
        "Pkg.add(collect(values(Pkg.Types.stdlibs())))",
        "for (uuid, info) in Pkg.dependencies()",
        "Pkg.add(info.name)",
        "end",
        "for (uuid, info) in Pkg.dependencies()",
        "if info.name in $(pkg_names_to_test)",
        "project_file = joinpath(info.source, \"Project.toml\")",
        "test_project_file = joinpath(info.source, \"test\", \"Project.toml\")",
        "if ispath(project_file)",
        "project = Pkg.TOML.parsefile(project_file)",
        "if haskey(project, \"deps\")",
        "project_deps = project[\"deps\"]",
        "for entry in keys(project_deps)",
        "Pkg.add(entry)",
        "end",
        "end",
        "if haskey(project, \"extras\")",
        "project_extras = project[\"extras\"]",
        "for entry in keys(project_extras)",
        "Pkg.add(entry)",
        "end",
        "end",
        "end",
        "if ispath(test_project_file)",
        "test_project = Pkg.TOML.parsefile(test_project_file)",
        "if haskey(test_project, \"deps\")",
        "test_project_deps = project[\"deps\"]",
        "for entry in keys(test_project_deps)",
        "Pkg.add(entry)",
        "end",
        "end",
        "end",
        "end",
        "end",
        "for (uuid, info) in Pkg.dependencies()",
        "Pkg.add(info.name)",
        "end"
    ]
    content = join(lines, "\n") * "\n"
    return content
end
