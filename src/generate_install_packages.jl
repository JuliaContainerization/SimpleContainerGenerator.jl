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
    no_test = config.no_test
    pkg_names_to_test = Vector{String}(undef, 0)
    for pkg in pkgs
        pkg_name = pkg[:name]
        if !(pkg_name in no_test)
            push!(pkg_names_to_test, pkg_name)
        end
    end
    pkgs_string = _to_packagespec_string(pkgs)
    return string("import Pkg\n",
                  "Pkg.add($(pkgs_string))\n",

                  "for (uuid, info) in Pkg.dependencies()\n",
                  "Pkg.add(info.name)\n",
                  "end\n",
        
        
                  "for (uuid, info) in Pkg.dependencies()\n",
                  "if info.name in $(pkg_names_to_test)\n",
                  
                  "project_file = joinpath(info.source, \"Project.toml\")\n",
                  
                  "test_project_file = joinpath(info.source, \"test\", \"Project.toml\")\n",
                  
                  "if ispath(project_file)\n",
                  
                  "project = Pkg.TOML.parsefile(project_file)\n",
                      
                  "if haskey(project, \"deps\")\n",
                      
                  "project_deps = project[\"deps\"]\n",
                          
                  "for entry in project_deps\n",
                          
                  "Pkg.add(entry)\n",
                              
                  "end\n",
                          
                  "end\n",
                      
                  "if haskey(project, \"extras\")\n",
                      
                  "project_extras = project[\"extras\"]\n",
                          
                  "for entry in project_extras\n",
                          
                  "Pkg.add(entry)\n",
                              
                  "end\n",
                          
                  "end\n",
                      
                  "end\n",
                  
                  "if ispath(test_project_file)\n",
                  
                  "test_project = Pkg.TOML.parsefile(test_project_file)\n",
                      
                  "if haskey(test_project, \"deps\")\n",
                      
                  "test_project_deps = project[\"deps\"]\n",
                          
                  "for entry in test_project_deps\n",
                          
                  "Pkg.add(entry)\n",
                              
                  "end\n",
                          
                  "end\n",
                      
                  "end\n",
                  
                  "end\n",
    
    
                  "for (uuid, info) in Pkg.dependencies()\n",
                  "Pkg.add(info.name)\n",
                  "end\n", 
    
    )
end
