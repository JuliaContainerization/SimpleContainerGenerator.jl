@inline function _generate_apt_install_command(config::Config)
    apt = config.apt
    pkgs = config.pkgs
    if isempty(config.apt)
        return ""
    else
        apt_list = join(apt, " ")
        return "RUN apt-get install -yq --no-install-recommends $(apt_list)"
    end
end

@inline function _generate_tests_must_pass_commands(config::Config)::Vector{String}
    tests_must_pass = config.tests_must_pass
    all_commands = String[]
    for pkg_name in tests_must_pass
        push!(all_commands,
              "RUN cd /tmp && JULIA_DEBUG=all /usr/bin/julia -e 'import Pkg; Pkg.test(string(:$(pkg_name)))'")
    end
    return all_commands
end

@inline function _generate_dockerfile_content(config::Config)
    julia_url, asc_url = _get_julia_url(config)
    apt_install = _generate_apt_install_command(config)
    tests_must_pass_commands = _generate_tests_must_pass_commands(config)
    parent_image = config.parent_image
    dockerfile_lines = String[
        "FROM $(parent_image)",

        "ENV DEBIAN_FRONTEND noninteractive",

        "RUN apt-get update",
        "RUN apt-get -yq dist-upgrade",
        "RUN apt-get update",
        "RUN apt-get -yq dist-upgrade",
        "$(apt_install)",
        "RUN apt-get update",
        "RUN apt-get -yq dist-upgrade",
        "RUN apt-get update",
        "RUN apt-get -yq dist-upgrade",
        "RUN apt-get clean",
        "RUN rm -rf /var/lib/apt/lists/*",
        "RUN echo \"en_US.UTF-8 UTF-8\" > /etc/locale.gen && locale-gen",
        "ENV SHELL=/bin/bash LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 PROMPT_COMMAND=\"echo -n [\$()]\"",

        "RUN mkdir -p /tmp/simplecontainergenerator_containers-julia-gpg-key",
        "RUN cd /tmp/simplecontainergenerator_containers-julia-gpg-key && curl https://julialang.org/juliareleases.asc --output juliareleases.asc",
        "RUN cd /tmp/simplecontainergenerator_containers-julia-gpg-key && gpg --import juliareleases.asc",
        "RUN rm -rf /tmp/simplecontainergenerator_containers-julia-gpg-key",

        "RUN mkdir -p /tmp/simplecontainergenerator_containers-download-julia",
        "RUN cd /tmp/simplecontainergenerator_containers-download-julia && wget -O julia.tar.gz $(julia_url)",
        "RUN cd /tmp/simplecontainergenerator_containers-download-julia && wget -O julia.tar.gz.asc $(asc_url)",
        "RUN cd /tmp/simplecontainergenerator_containers-download-julia && gpg --verify julia.tar.gz.asc",
        "RUN rm -rf /opt",
        "RUN mkdir -p /opt",
        "RUN cd /tmp/simplecontainergenerator_containers-download-julia && tar xzf julia.tar.gz -C /opt --strip-components=1",
        "RUN rm -rf /tmp/simplecontainergenerator_containers-download-julia",

        "RUN rm -rf /tmp/simplecontainergenerator-containers-build-depot",
        "RUN mkdir -p /tmp/simplecontainergenerator-containers-build-depot ",
        "RUN cd /tmp && JULIA_DEPOT_PATH=/tmp/simplecontainergenerator-containers-build-depot /opt/bin/julia -e 'import InteractiveUtils; InteractiveUtils.versioninfo(; verbose=true)'",
        "RUN rm -rf /tmp/simplecontainergenerator-containers-build-depot",
        "RUN rm -rf /opt/etc/julia/startup.jl",
        "RUN rm -rf /opt/share/julia/compiled",
        "RUN rm -rf /usr/bin/julia",
        "RUN mkdir -p /opt/etc/julia",

        "RUN rm -rf /opt/simplecontainergenerator_containers",

        "RUN mkdir -p /opt/simplecontainergenerator_containers",
        "RUN mkdir -p /opt/simplecontainergenerator_containers/backup_of_dockerfile",
        "RUN mkdir -p /opt/simplecontainergenerator_containers/depot_backup_simplecontainergenerator",
        "RUN mkdir -p /opt/simplecontainergenerator_containers/depot_backup_packagecompiler",
        "RUN mkdir -p /opt/simplecontainergenerator_containers/packagecompiler_depot",
        "RUN mkdir -p /opt/simplecontainergenerator_containers/julia_depot",
        "RUN mkdir -p /opt/simplecontainergenerator_containers/julia_project",
        "RUN mkdir -p /opt/simplecontainergenerator_containers/sysimage",

        "RUN mkdir -p /usr/bin",

        "COPY Dockerfile /opt/simplecontainergenerator_containers/backup_of_dockerfile/Dockerfile",

        "COPY simplecontainergenerator_container_files/backups_of_simplecontainergenerator_1.jl /opt/simplecontainergenerator_containers/backups_of_simplecontainergenerator_1.jl",
        "COPY simplecontainergenerator_container_files/backups_of_simplecontainergenerator_2.jl /opt/simplecontainergenerator_containers/backups_of_simplecontainergenerator_2.jl",
        "COPY simplecontainergenerator_container_files/install_packages.jl /opt/simplecontainergenerator_containers/install_packages.jl",
        "COPY simplecontainergenerator_container_files/julia.sh /usr/bin/julia",
        "COPY simplecontainergenerator_container_files/no_sysimage_julia.sh /usr/bin/no_sysimage_julia",
        "COPY simplecontainergenerator_container_files/packagecompiler_install.jl /opt/simplecontainergenerator_containers/packagecompiler_install.jl",
        "COPY simplecontainergenerator_container_files/packagecompiler_run.jl /opt/simplecontainergenerator_containers/packagecompiler_run.jl",
        "COPY simplecontainergenerator_container_files/precompile_execution.jl /opt/simplecontainergenerator_containers/precompile_execution.jl",
        "COPY simplecontainergenerator_container_files/startup.jl /opt/etc/julia/startup.jl",

        "RUN chmod 444 /opt/etc/julia/startup.jl",
        "RUN chmod 555 /usr/bin/julia",
        "RUN chmod 555 /usr/bin/no_sysimage_julia",

        "RUN cd /tmp && JULIA_DEBUG=all SIMPLECONTAINERGENERATOR_CONTAINER_NO_TEMP_DEPOT=\"true\" /usr/bin/no_sysimage_julia /opt/simplecontainergenerator_containers/install_packages.jl",

        "RUN cd /tmp && JULIA_DEBUG=all /opt/bin/julia /opt/simplecontainergenerator_containers/backups_of_simplecontainergenerator_1.jl",
        "RUN cd /tmp && JULIA_DEBUG=all /opt/bin/julia /opt/simplecontainergenerator_containers/backups_of_simplecontainergenerator_2.jl",

        "RUN cd /tmp && JULIA_DEBUG=all /opt/bin/julia /opt/simplecontainergenerator_containers/packagecompiler_install.jl",
        "RUN cd /tmp && SIMPLECONTAINERGENERATOR_CONTAINER_NO_TEMP_DEPOT=\"true\" /usr/bin/no_sysimage_julia /opt/simplecontainergenerator_containers/packagecompiler_run.jl",
        "RUN cd /tmp && JULIA_DEBUG=all /usr/bin/no_sysimage_julia -e 'import InteractiveUtils; InteractiveUtils.versioninfo(; verbose=true)'",
        "RUN cd /tmp && JULIA_DEBUG=all /usr/bin/julia -e 'import InteractiveUtils; InteractiveUtils.versioninfo(; verbose=true)'",

        tests_must_pass_commands...,

        "RUN rm -rf /opt/bin/julia/compiled",
        "RUN rm -rf /opt/etc/julia/compiled",
        "RUN rm -rf /opt/share/julia/compiled",
        "RUN rm -rf /opt/simplecontainergenerator_containers/depot_backup_simplecontainergenerator/compiled",
        "RUN rm -rf /opt/simplecontainergenerator_containers/depot_backup_packagecompiler/compiled",
        "RUN rm -rf /opt/simplecontainergenerator_containers/packagecompiler_depot/compiled",
        "RUN rm -rf /opt/simplecontainergenerator_containers/julia_depot/compiled",
        "RUN rm -rf /opt/simplecontainergenerator_containers/julia_project/compiled",
        "RUN rm -rf /opt/simplecontainergenerator_containers/sysimage/compiled",

        "RUN find /opt -type d -print0 | xargs -0 chmod a+rx",
        "RUN find /opt -type f -print0 | xargs -0 chmod a+r",
        "RUN chmod a+rx /opt/bin/julia",
        "RUN chmod a+rx /usr/bin/julia",
        "RUN chmod a+rx /usr/bin/no_sysimage_julia",

        "ENTRYPOINT [\"/bin/bash\", \"-c\"]",
    ]
    dockerfile_content = join(dockerfile_lines, "\n") * "\n"

    return dockerfile_content
end

@inline function _write_all_docker_files(config::Config,
                                         directory::AbstractString)
    files = Dict()
    files[["Dockerfile"]] = _generate_dockerfile_content(config)

    files[["simplecontainergenerator_container_files", "backups_of_simplecontainergenerator_1.jl"]] = _generate_backupsofsimplecontainergenerator_content_1(config)
    files[["simplecontainergenerator_container_files", "backups_of_simplecontainergenerator_2.jl"]] = _generate_backupsofsimplecontainergenerator_content_2(config)
    files[["simplecontainergenerator_container_files", "install_packages.jl"]] = _generate_install_packages_content(config)
    files[["simplecontainergenerator_container_files", "julia.sh"]] = _generate_use_sysimage_julia_script_content(config)
    files[["simplecontainergenerator_container_files", "no_sysimage_julia.sh"]] = _generate_do_not_use_sysimage_julia_script_content(config)
    files[["simplecontainergenerator_container_files", "packagecompiler_install.jl"]] = _generate_packagecompiler_install_content(config)
    files[["simplecontainergenerator_container_files", "packagecompiler_run.jl"]] = _generate_packagecompiler_run_content(config)
    files[["simplecontainergenerator_container_files", "precompile_execution.jl"]] = _generate_precompile_execution_content(config)
    files[["simplecontainergenerator_container_files", "startup.jl"]] = _generate_global_startup_file_content(config)
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
