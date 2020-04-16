@inline function _generate_apt_install_command(config::Config)
    apt = config.apt
    pkgs = config.pkgs
    if isempty(config.apt)
        return ""
    else
        apt_list = join(apt, " ")
        return " && apt-get install  -yq --no-install-recommends $(apt_list)"
    end
end

@inline function _generate_dockerfile_content(config::Config)
    julia_url, asc_url = _get_julia_url(config)
    apt_install = _generate_apt_install_command(config)
    section_01_from = "FROM ubuntu:latest\nENV DEBIAN_FRONTEND noninteractive\n"
    section_02_apt = string("RUN apt-get update",
                            " && apt-get -yq dist-upgrade",
                            " && apt-get update",
                            " && apt-get -yq dist-upgrade",
                            apt_install,
                            " && apt-get update",
                            " && apt-get -yq dist-upgrade",
                            " && apt-get update",
                            " && apt-get -yq dist-upgrade",
                            " && apt-get clean",
                            " && rm -rf /var/lib/apt/lists/*\n")
    section_03_utf_locale = string("RUN echo \"en_US.UTF-8 UTF-8\" > ",
                                "/etc/locale.gen && locale-gen\n")

    section_04_basic_environment = string("ENV SHELL=/bin/bash ",
                                       "LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 ",
                                       "LANGUAGE=en_US.UTF-8 ",
                                       "PROMPT_COMMAND=\"echo -n [\$()]\"\n")
    section_05_julia_gpg_key = string("RUN cd /tmp && ",
                                   "mkdir -p /tmp/simplecontainergenerator_containers-julia-gpg-key && ",
                                   "cd /tmp/simplecontainergenerator_containers-julia-gpg-key && ",
                                   "curl https://julialang.org/juliareleases.asc --output juliareleases.asc && ",
                                   "gpg --import juliareleases.asc && ",
                                   "cd /tmp && ",
                                   "rm -rf /tmp/simplecontainergenerator_containers-julia-gpg-key\n")
    section_06_install_julia = string("RUN cd /tmp && ",
                                   "mkdir -p /opt && ",
                                   "mkdir -p /tmp/simplecontainergenerator_containers-download-julia && ",
                                   "cd /tmp/simplecontainergenerator_containers-download-julia && ",
                                   # "curl $(julia_url) --output julia.tar.gz && ",
                                   "wget -O julia.tar.gz $(julia_url) && ",
                                   # "curl $(asc_url) --output julia.tar.gz.asc && ",
                                   "wget -O julia.tar.gz.asc $(asc_url) && ",
                                   "gpg --verify julia.tar.gz.asc && ",
                                   "tar xzf julia.tar.gz -C /opt --strip-components=1 && ",
                                   "cd /tmp && ",
                                   "rm -rf /tmp/simplecontainergenerator_containers-download-julia && ",
                                   "cd /tmp && ",
                                   "rm -rf /tmp/simplecontainergenerator-containers-build-depot && ",
                                   "mkdir -p /tmp/simplecontainergenerator-containers-build-depot && ",
                                   "JULIA_DEPOT_PATH=/tmp/simplecontainergenerator-containers-build-depot /opt/bin/julia -e 'import InteractiveUtils; InteractiveUtils.versioninfo(; verbose=true)' && ",
                                   "rm -rf /opt/share/julia/compiled\n")
    section_07_make_opt_directories = string("RUN mkdir -p /opt/simplecontainergenerator_containers/julia_project && ",
                                          "mkdir -p /opt/simplecontainergenerator_containers/julia_depot &&",
                                          "mkdir -p /opt/simplecontainergenerator_containers/sysimage\n",)
    section_08_startup = string("RUN rm -rf /opt/etc/julia/startup.jl && ",
                             "mkdir -p /opt/etc/julia\n",
                             "COPY simplecontainergenerator_container_files/startup.jl /opt/etc/julia/startup.jl\n",
                             "RUN chmod 444 /opt/etc/julia/startup.jl\n")
    section_09_julia = string("RUN rm -rf /usr/bin/julia && ",
                                   "mkdir -p /usr/bin\n",
                                   "COPY simplecontainergenerator_container_files/julia.sh /usr/bin/julia\n",
                                   "COPY simplecontainergenerator_container_files/no_sysimage_julia.sh /usr/bin/no_sysimage_julia\n",
                                   "RUN chmod 555 /usr/bin/julia\n",
                                   "RUN chmod 555 /usr/bin/no_sysimage_julia\n")
    section_10_install_packages = string("RUN rm -rf /opt/simplecontainergenerator_containers/install_packages.jl && ",
                                      "mkdir -p /opt/simplecontainergenerator_containers\n",
                                      "COPY simplecontainergenerator_container_files/install_packages.jl /opt/simplecontainergenerator_containers/install_packages.jl\n",
                                      "RUN cd /tmp && ",
                                      "JULIA_DEBUG=all SIMPLECONTAINERGENERATOR_CONTAINER_NO_TEMP_DEPOT=\"true\" /usr/bin/no_sysimage_julia /opt/simplecontainergenerator_containers/install_packages.jl\n")
    section_11_precompile = string("RUN rm -rf /opt/simplecontainergenerator_containers/precompile.jl && ",
                                "mkdir -p /opt/simplecontainergenerator_containers\n",
                                "COPY simplecontainergenerator_container_files/precompile.jl /opt/simplecontainergenerator_containers/precompile.jl\n",)
    section_12_packagecompiler = string("RUN rm -rf /opt/simplecontainergenerator_containers/packagecompiler.jl && ",
                                     "mkdir -p /opt/simplecontainergenerator_containers\n",
                                     "COPY simplecontainergenerator_container_files/packagecompiler.jl /opt/simplecontainergenerator_containers/packagecompiler.jl\n",
                                     "RUN cd /tmp && ",
                                     "JULIA_DEBUG=all SIMPLECONTAINERGENERATOR_CONTAINER_NO_TEMP_DEPOT=\"true\" /usr/bin/no_sysimage_julia /opt/simplecontainergenerator_containers/packagecompiler.jl\n")
    section_13_try_no_sysimage = "RUN JULIA_DEBUG=all /usr/bin/no_sysimage_julia -e 'import InteractiveUtils; InteractiveUtils.versioninfo(; verbose=true)'\n"
    section_14_try_sysimage = "RUN JULIA_DEBUG=all /usr/bin/julia -e 'import InteractiveUtils; InteractiveUtils.versioninfo(; verbose=true)'\n"
    section_15_delete_all_compiled_cache = string("RUN rm -rf /opt/bin/julia/compiled && ",
                                                  "rm -rf /opt/etc/julia/compiled && ",
                                                  "rm -rf /opt/share/julia/compiled && ",
                                                  "rm -rf /opt/simplecontainergenerator_containers/julia_depot/compiled  && ",
                                                  "rm -rf /opt/simplecontainergenerator_containers/julia_project/compiled  && ",
                                                  "rm -rf /opt/simplecontainergenerator_containers/sysimage/compiled\n")
    penultimate_section_fix_permissions = string("RUN find /opt -type d -print0 | xargs -0 chmod a+rx\n",
                                                 "RUN find /opt -type f -print0 | xargs -0 chmod a+r\n",
                                                 "RUN chmod a+rx /opt/bin/julia && ",
                                                 "chmod a+rx /usr/bin/julia && ",
                                                 "chmod a+rx /usr/bin/no_sysimage_julia\n")
    final_section_entrypoint = "ENTRYPOINT [\"/bin/bash\", \"-c\"]\n"
    return string(section_01_from,
                  section_02_apt,
                  section_03_utf_locale,
                  section_04_basic_environment,
                  section_05_julia_gpg_key,
                  section_06_install_julia,
                  section_07_make_opt_directories,
                  section_08_startup,
                  section_09_julia,
                  section_10_install_packages,
                  section_11_precompile,
                  section_12_packagecompiler,
                  section_13_try_no_sysimage,
                  section_14_try_sysimage,
                  section_15_delete_all_compiled_cache,
                  penultimate_section_fix_permissions,
                  final_section_entrypoint)
end

@inline function _write_all_docker_files(config::Config,
                                         directory::AbstractString)
    files = Dict()
    files[["Dockerfile"]] = _generate_dockerfile_content(config)
    files[["simplecontainergenerator_container_files", "startup.jl"]] = _generate_global_startup_file_content(config)
    files[["simplecontainergenerator_container_files", "julia.sh"]] = _generate_use_sysimage_julia_script_content(config)
    files[["simplecontainergenerator_container_files", "no_sysimage_julia.sh"]] = _generate_do_not_use_sysimage_julia_script_content(config)
    files[["simplecontainergenerator_container_files", "install_packages.jl"]] = _generate_install_packages_content(config)
    files[["simplecontainergenerator_container_files", "precompile.jl"]] = _generate_precompile_content(config)
    files[["simplecontainergenerator_container_files", "packagecompiler.jl"]] = _generate_packagecompiler_content(config)
    rm(joinpath(directory, "Dockerfile"); force = true, recursive = true)
    rm(joinpath(directory, "simplecontainergenerator_container_files"); force = true, recursive = true)
    mkpath(directory)
    for (parts, filecontent) in files
        fullfilepath = joinpath(directory, parts...)
        rm(fullfilepath; force = true, recursive = true)
        mkpath(dirname(fullfilepath))
        open(fullfilepath, "w") do io
            print(io, filecontent)
        end
        @debug("Wrote file: \"$(fullfilepath)\"")
    end
    return directory
end
