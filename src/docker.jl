function _generate_apt_install_command(config::Config)
    apt = config.apt
    pkgs = config.pkgs
    if isempty(config.apt)
        return ""
    else
        apt_list = join(apt, " ")
        return " && apt-get install  -yq --no-install-recommends $(apt_list)"
    end
end

function _generate_dockerfile_content(config::Config)
    julia_url = _get_julia_url(config)
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
                                   "mkdir -p /tmp/stopgapcontainers-julia-gpg-key && ",
                                   "cd /tmp/stopgapcontainers-julia-gpg-key && ",
                                   "wget -q https://julialang.org/juliareleases.asc && ",
                                   "gpg --import juliareleases.asc && ",
                                   "cd /tmp && ",
                                   "rm -rf /tmp/stopgapcontainers-julia-gpg-key\n")
    section_06_install_julia = string("RUN cd /tmp && ",
                                   "mkdir -p /usr && ",
                                   "mkdir -p /tmp/stopgapcontainers-download-julia && ",
                                   "cd /tmp/stopgapcontainers-download-julia && ",
                                   "wget -q -O julia.tar.gz $(julia_url) && ",
                                   "wget -q -O julia.tar.gz.asc $(julia_url).asc && ",
                                   "gpg --verify julia.tar.gz.asc && ",
                                   "tar xzf julia.tar.gz -C /usr --strip-components=1 && ",
                                   "cd /tmp && ",
                                   "rm -rf /tmp/stopgapcontainers-download-julia && ",
                                   "cd /tmp && ",
                                   "rm -rf /tmp/stopgap-build-depot && ",
                                   "mkdir -p /tmp/stopgap-build-depot && ",
                                   "JULIA_DEPOT_PATH=/tmp/stopgap-build-depot /usr/bin/julia -e 'import InteractiveUtils; InteractiveUtils.versioninfo(verbose=true)' && ",
                                   "rm -rf /usr/share/julia/compiled &&",
                                   "mkdir -p /usr/share/julia/compiled\n")
    section_07_make_opt_directories = string("RUN mkdir -p /opt/stopgapcontainers/julia_project && ",
                                          "mkdir -p /opt/stopgapcontainers/julia_depot &&",
                                          "mkdir -p /opt/stopgapcontainers/sysimage\n",)
    section_08_startup = string("RUN rm -rf /usr/etc/julia/startup.jl && ",
                             "mkdir -p /usr/etc/julia\n",
                             "COPY startup.jl /usr/etc/julia/startup.jl\n",
                             "RUN chmod 444 /usr/etc/julia/startup.jl\n")
    section_09_stopgap_julia = string("RUN rm -rf /usr/bin/stopgap_julia && ",
                                   "mkdir -p /usr/bin\n",
                                   "COPY stopgap_julia.sh /usr/bin/stopgap_julia\n",
                                   "COPY no_sysimage_stopgap_julia.sh /usr/bin/no_sysimage_stopgap_julia\n",
                                   "RUN chmod 555 /usr/bin/stopgap_julia\n",
                                   "RUN chmod 555 /usr/bin/no_sysimage_stopgap_julia\n")
    section_10_install_packages = string("RUN rm -rf /opt/stopgapcontainers/install_packages.jl && ",
                                      "mkdir -p /opt/stopgapcontainers\n",
                                      "COPY install_packages.jl /opt/stopgapcontainers/install_packages.jl\n",
                                      "RUN cd /tmp && ",
                                      "STOPGAP_CONTAINER_NO_TEMP_DEPOT=\"true\" /usr/bin/no_sysimage_stopgap_julia /opt/stopgapcontainers/install_packages.jl\n")
    section_11_precompile = string("RUN rm -rf /opt/stopgapcontainers/precompile.jl && ",
                                "mkdir -p /opt/stopgapcontainers\n",
                                "COPY precompile.jl /opt/stopgapcontainers/precompile.jl\n",)
    section_12_packagecompiler = string("RUN rm -rf /opt/stopgapcontainers/packagecompiler.jl && ",
                                     "mkdir -p /opt/stopgapcontainers\n",
                                     "COPY packagecompiler.jl /opt/stopgapcontainers/packagecompiler.jl\n",
                                     "RUN cd /tmp && ",
                                     "STOPGAP_CONTAINER_NO_TEMP_DEPOT=\"true\" /usr/bin/no_sysimage_stopgap_julia /opt/stopgapcontainers/packagecompiler.jl\n")
    final_line_entrypoint = "ENTRYPOINT [\"/bin/bash\"]\n"
    section_13_try_no_sysimage = "RUN /usr/bin/no_sysimage_stopgap_julia -e 'import InteractiveUtils; InteractiveUtils.versioninfo(verbose=true)'\n"
    section_14_try_sysimage = "RUN /usr/bin/stopgap_julia -e 'import InteractiveUtils; InteractiveUtils.versioninfo(verbose=true)'\n"
    return string(section_01_from,
                  section_02_apt,
                  section_03_utf_locale,
                  section_04_basic_environment,
                  section_05_julia_gpg_key,
                  section_06_install_julia,
                  section_07_make_opt_directories,
                  section_08_startup,
                  section_09_stopgap_julia,
                  section_10_install_packages,
                  section_11_precompile,
                  section_12_packagecompiler,
                  section_13_try_no_sysimage,
                  section_14_try_sysimage,
                  # section_15,
                  # section_16,
                  # section_17,
                  # section_18,
                  # section_19,
                  # section_20,
                  final_line_entrypoint)
end

function _write_all_docker_files(config::Config, directory::AbstractString)
    files = Dict()
    files["Dockerfile"] = _generate_dockerfile_content(config)
    files["startup.jl"] = _generate_global_startup_file_content(config)
    files["stopgap_julia.sh"] = _generate_stopgap_julia_script_content(config)
    files["no_sysimage_stopgap_julia.sh"] = _generate_no_sysimage_stopgap_julia_script_content(config)
    files["install_packages.jl"] = _generate_install_packages_content(config)
    files["precompile.jl"] = _generate_precompile_content(config)
    files["packagecompiler.jl"] = _generate_packagecompiler_content(config)
    for (filename, filecontent) in files
        fullfilepath = joinpath(directory, filename)
        rm(fullfilepath; force = true, recursive = true)
        mkpath(dirname(fullfilepath))
        open(fullfilepath, "w") do io
            print(io, filecontent)
        end
        @debug("Wrote file: \"$(fullfilepath)\"")
    end
    return directory
end
