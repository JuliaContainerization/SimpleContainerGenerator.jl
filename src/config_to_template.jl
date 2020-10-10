function _generate_apt_install_command(config::Config)
    apt = config.apt
    pkgs = config.pkgs
    if isempty(config.apt)
        return ""
    else
        apt_list = join(apt, " ")
        return "apt-get install -yq --no-install-recommends $(apt_list)"
    end
end

function _generate_tests_must_pass_commands(config::Config)::Vector{String}
    tests_must_pass = config.tests_must_pass
    all_commands = String[]
    for pkg_name in tests_must_pass
        push!(all_commands,
              "cd /tmp; JULIA_DEBUG=all /usr/bin/julia -e 'println(:current_stage_is_the_tests_must_pass_stage); println(:now_testing_$(pkg_name)); import Pkg; Pkg.test(string(:$(pkg_name)))'")
    end
    return all_commands
end

function Template(config::Config)
    apt_install = _generate_apt_install_command(config)
    julia_url, asc_url = _get_julia_url(config)
    parent_image = config.parent_image
    tests_must_pass_commands = _generate_tests_must_pass_commands(config)

    file_list_vector = File[
        File(_generate_backupsofsimplecontainergenerator_content_1(config),
             "/tmp/staging/copyfiles/opt/simplecontainergenerator_containers",
             "backups_of_simplecontainergenerator_1.jl"),
        File(_generate_backupsofsimplecontainergenerator_content_2(config),
             "/tmp/staging/copyfiles/opt/simplecontainergenerator_containers",
             "backups_of_simplecontainergenerator_2.jl"),
        File(_generate_install_packages_content(config),
             "/tmp/staging/copyfiles/opt/simplecontainergenerator_containers",
             "install_packages.jl"),
        File(_generate_use_sysimage_julia_script_content(config),
             "/tmp/staging/copyfiles/usr/bin",
             "julia"),
        File(_generate_do_not_use_sysimage_julia_script_content(config),
             "/tmp/staging/copyfiles/usr/bin",
             "no_sysimage_julia"),
        File(_generate_packagecompiler_install_content(config),
             "/tmp/staging/copyfiles/opt/simplecontainergenerator_containers",
             "packagecompiler_install.jl"),
        File(_generate_packagecompiler_run_content(config),
             "/tmp/staging/copyfiles/opt/simplecontainergenerator_containers",
             "packagecompiler_run.jl"),
        File(_generate_precompile_execution_content(config),
             "/tmp/staging/copyfiles/opt/simplecontainergenerator_containers",
             "precompile_execution.jl"),
        File(_generate_global_startup_file_content(config),
             "/tmp/staging/copyfiles/opt/etc/julia",
             "startup.jl"),
    ]

    step_list_vector = Vector{AbstractStep}(undef, 0)
    #
    push!(step_list_vector, DockerOnlyLine("FROM $(parent_image)"))
    #
    push!(step_list_vector, EnvStep("DEBIAN_FRONTEND", "noninteractive"))
    #
    push!(step_list_vector, DockerOnlyLine("RUN apt-get update"))
    push!(step_list_vector, DockerOnlyLine("RUN apt-get -yq dist-upgrade"))
    push!(step_list_vector, DockerOnlyLine("RUN apt-get update"))
    push!(step_list_vector, DockerOnlyLine("RUN apt-get -yq dist-upgrade"))
    push!(step_list_vector, DockerOnlyLine("RUN $(apt_install)"))
    push!(step_list_vector, DockerOnlyLine("RUN apt-get update"))
    push!(step_list_vector, DockerOnlyLine("RUN apt-get -yq dist-upgrade"))
    push!(step_list_vector, DockerOnlyLine("RUN apt-get update"))
    push!(step_list_vector, DockerOnlyLine("RUN apt-get -yq dist-upgrade"))
    push!(step_list_vector, DockerOnlyLine("RUN apt-get clean"))
    #
    push!(step_list_vector, PlaceholderYumStep())
    #
    push!(step_list_vector, RunStep("rm -rf /var/lib/apt/lists/*"))
    push!(step_list_vector, DockerOnlyLine("RUN echo \"en_US.UTF-8 UTF-8\" > /etc/locale.gen && locale-gen"))
    #
    push!(step_list_vector, EnvStep("SHELL", "/bin/bash"))
    push!(step_list_vector, EnvStep("LC_ALL", "en_US.UTF-8"))
    push!(step_list_vector, EnvStep("LANG", "en_US.UTF-8"))
    push!(step_list_vector, EnvStep("LANGUAGE", "en_US.UTF-8"))
    push!(step_list_vector, EnvStep("PROMPT_COMMAND", "\"echo -n [\$()]\""))
    #
    push!(step_list_vector, RunStep("mkdir -p /tmp/simplecontainergenerator_containers-julia-gpg-key"))
    push!(step_list_vector, RunStep("cd /tmp/simplecontainergenerator_containers-julia-gpg-key && curl https://julialang.org/assets/juliareleases.asc --output juliareleases.asc"))
    push!(step_list_vector, RunStep("cd /tmp/simplecontainergenerator_containers-julia-gpg-key && gpg --import juliareleases.asc"))
    push!(step_list_vector, RunStep("rm -rf /tmp/simplecontainergenerator_containers-julia-gpg-key"))
    #
    push!(step_list_vector, RunStep("mkdir -p /tmp/simplecontainergenerator_containers-download-julia"))
    push!(step_list_vector, RunStep("cd /tmp/simplecontainergenerator_containers-download-julia && wget -O julia.tar.gz $(julia_url)"))
    push!(step_list_vector, RunStep("cd /tmp/simplecontainergenerator_containers-download-julia && wget -O julia.tar.gz.asc $(asc_url)"))
    push!(step_list_vector, RunStep("cd /tmp/simplecontainergenerator_containers-download-julia && gpg --verify julia.tar.gz.asc"))
    push!(step_list_vector, RunStep("mkdir -p /opt"))
    push!(step_list_vector, RunStep("cd /tmp/simplecontainergenerator_containers-download-julia && tar xzf julia.tar.gz -C /opt --strip-components=1"))
    push!(step_list_vector, RunStep("rm -rf /tmp/simplecontainergenerator_containers-download-julia"))
    #
    push!(step_list_vector, RunStep("rm -rf /tmp/simplecontainergenerator-containers-build-depot"))
    push!(step_list_vector, RunStep("mkdir -p /tmp/simplecontainergenerator-containers-build-depot"))
    push!(step_list_vector, RunStep("cd /tmp; JULIA_DEPOT_PATH=/tmp/simplecontainergenerator-containers-build-depot /opt/bin/julia -e 'import InteractiveUtils; InteractiveUtils.versioninfo(; verbose=true)'"))
    push!(step_list_vector, RunStep("rm -rf /tmp/simplecontainergenerator-containers-build-depot"))
    #
    push!(step_list_vector, RunStep("rm -rf /opt/etc/julia/startup.jl"))
    push!(step_list_vector, RunStep("rm -rf /opt/share/julia/compiled"))
    push!(step_list_vector, RunStep("rm -rf /usr/bin/julia"))
    push!(step_list_vector, RunStep("mkdir -p /opt/etc/julia"))
    #
    push!(step_list_vector, RunStep("mkdir -p /opt/simplecontainergenerator_containers"))
    push!(step_list_vector, RunStep("mkdir -p /opt/simplecontainergenerator_containers/backup_of_dockerfile"))
    push!(step_list_vector, RunStep("mkdir -p /opt/simplecontainergenerator_containers/depot_backup_simplecontainergenerator"))
    push!(step_list_vector, RunStep("mkdir -p /opt/simplecontainergenerator_containers/depot_backup_packagecompiler"))
    push!(step_list_vector, RunStep("mkdir -p /opt/simplecontainergenerator_containers/packagecompiler_depot"))
    push!(step_list_vector, RunStep("mkdir -p /opt/simplecontainergenerator_containers/julia_depot"))
    push!(step_list_vector, RunStep("mkdir -p /opt/simplecontainergenerator_containers/julia_project"))
    push!(step_list_vector, RunStep("mkdir -p /opt/simplecontainergenerator_containers/sysimage"))
    #
    push!(step_list_vector, RunStep("mkdir -p /usr/bin"))
    #
    push!(step_list_vector, PlaceholderDockerCopyFiles())
    #
    push!(step_list_vector, RunStep("rm -rf /opt/simplecontainergenerator_containers/backups_of_simplecontainergenerator_1.jl"))
    push!(step_list_vector, RunStep("rm -rf /opt/simplecontainergenerator_containers/backups_of_simplecontainergenerator_2.jl"))
    push!(step_list_vector, RunStep("rm -rf /opt/simplecontainergenerator_containers/install_packages.jl"))
    push!(step_list_vector, RunStep("rm -rf /usr/bin/julia"))
    push!(step_list_vector, RunStep("rm -rf /usr/bin/no_sysimage_julia"))
    push!(step_list_vector, RunStep("rm -rf /opt/simplecontainergenerator_containers/packagecompiler_install.jl"))
    push!(step_list_vector, RunStep("rm -rf /opt/simplecontainergenerator_containers/packagecompiler_run.jl"))
    push!(step_list_vector, RunStep("rm -rf /opt/simplecontainergenerator_containers/precompile_execution.jl"))
    push!(step_list_vector, RunStep("rm -rf /opt/etc/julia/startup.jl"))
    #
    push!(step_list_vector, RunStep("mkdir -p /opt/simplecontainergenerator_containers"))
    push!(step_list_vector, RunStep("mkdir -p /usr/bin"))
    push!(step_list_vector, RunStep("mkdir -p /opt/etc/julia"))
    #
    push!(step_list_vector, RunStep("cp /tmp/staging/copyfiles/opt/simplecontainergenerator_containers/backups_of_simplecontainergenerator_1.jl /opt/simplecontainergenerator_containers/backups_of_simplecontainergenerator_1.jl"))
    push!(step_list_vector, RunStep("cp /tmp/staging/copyfiles/opt/simplecontainergenerator_containers/backups_of_simplecontainergenerator_2.jl /opt/simplecontainergenerator_containers/backups_of_simplecontainergenerator_2.jl"))
    push!(step_list_vector, RunStep("cp /tmp/staging/copyfiles/opt/simplecontainergenerator_containers/install_packages.jl /opt/simplecontainergenerator_containers/install_packages.jl"))
    push!(step_list_vector, RunStep("cp /tmp/staging/copyfiles/usr/bin/julia /usr/bin/julia"))
    push!(step_list_vector, RunStep("cp /tmp/staging/copyfiles/usr/bin/no_sysimage_julia /usr/bin/no_sysimage_julia"))
    push!(step_list_vector, RunStep("cp /tmp/staging/copyfiles/opt/simplecontainergenerator_containers/packagecompiler_install.jl /opt/simplecontainergenerator_containers/packagecompiler_install.jl"))
    push!(step_list_vector, RunStep("cp /tmp/staging/copyfiles/opt/simplecontainergenerator_containers/packagecompiler_run.jl /opt/simplecontainergenerator_containers/packagecompiler_run.jl"))
    push!(step_list_vector, RunStep("cp /tmp/staging/copyfiles/opt/simplecontainergenerator_containers/precompile_execution.jl /opt/simplecontainergenerator_containers/precompile_execution.jl"))
    push!(step_list_vector, RunStep("cp /tmp/staging/copyfiles/opt/etc/julia/startup.jl /opt/etc/julia/startup.jl"))
    #
    push!(step_list_vector, RunStep("rm -rf /tmp/staging"))
    #
    push!(step_list_vector, RunStep("chmod 444 /opt/etc/julia/startup.jl"))
    push!(step_list_vector, RunStep("chmod 555 /usr/bin/julia"))
    push!(step_list_vector, RunStep("chmod 555 /usr/bin/no_sysimage_julia"))
    #
    push!(step_list_vector, RunStep("cd /tmp; JULIA_DEBUG=all SIMPLECONTAINERGENERATOR_CONTAINER_NO_TEMP_DEPOT=\"true\" /usr/bin/no_sysimage_julia /opt/simplecontainergenerator_containers/install_packages.jl"))
    #
    push!(step_list_vector, RunStep("cd /tmp; JULIA_DEBUG=all /opt/bin/julia /opt/simplecontainergenerator_containers/backups_of_simplecontainergenerator_1.jl"))
    push!(step_list_vector, RunStep("cd /tmp; JULIA_DEBUG=all /opt/bin/julia /opt/simplecontainergenerator_containers/backups_of_simplecontainergenerator_2.jl"))
    #
    push!(step_list_vector, RunStep("cd /tmp; JULIA_DEBUG=all /opt/bin/julia /opt/simplecontainergenerator_containers/packagecompiler_install.jl"))
    push!(step_list_vector, RunStep("cd /tmp; SIMPLECONTAINERGENERATOR_CONTAINER_NO_TEMP_DEPOT=\"true\" /usr/bin/no_sysimage_julia /opt/simplecontainergenerator_containers/packagecompiler_run.jl"))
    push!(step_list_vector, RunStep("cd /tmp; JULIA_DEBUG=all /usr/bin/no_sysimage_julia -e 'import InteractiveUtils; InteractiveUtils.versioninfo(; verbose=true)'"))
    push!(step_list_vector, RunStep("cd /tmp; JULIA_DEBUG=all /usr/bin/julia -e 'import InteractiveUtils; InteractiveUtils.versioninfo(; verbose=true)'"))
    #
    for cmd in tests_must_pass_commands
        push!(step_list_vector, RunStep(cmd))
    end
    #
    push!(step_list_vector, RunStep("rm -rf /opt/bin/julia/compiled"))
    push!(step_list_vector, RunStep("rm -rf /opt/etc/julia/compiled"))
    push!(step_list_vector, RunStep("rm -rf /opt/share/julia/compiled"))
    push!(step_list_vector, RunStep("rm -rf /opt/simplecontainergenerator_containers/depot_backup_simplecontainergenerator/compiled"))
    push!(step_list_vector, RunStep("rm -rf /opt/simplecontainergenerator_containers/depot_backup_packagecompiler/compiled"))
    push!(step_list_vector, RunStep("rm -rf /opt/simplecontainergenerator_containers/packagecompiler_depot/compiled"))
    push!(step_list_vector, RunStep("rm -rf /opt/simplecontainergenerator_containers/julia_depot/compiled"))
    push!(step_list_vector, RunStep("rm -rf /opt/simplecontainergenerator_containers/julia_project/compiled"))
    push!(step_list_vector, RunStep("rm -rf /opt/simplecontainergenerator_containers/sysimage/compiled"))
    #
    push!(step_list_vector, RunStep("find /opt -type d -print0 | xargs -0 chmod a+rx"))
    push!(step_list_vector, RunStep("find /opt -type f -print0 | xargs -0 chmod a+r"))
    push!(step_list_vector, RunStep("chmod a+rx /opt/bin/julia"))
    push!(step_list_vector, RunStep("chmod a+rx /usr/bin/julia"))
    push!(step_list_vector, RunStep("chmod a+rx /usr/bin/no_sysimage_julia"))
    #
    push!(step_list_vector, DockerOnlyLine("RUN mkdir -p /opt/simplecontainergenerator_containers/backup_of_dockerfile"))
    push!(step_list_vector, DockerOnlyLine("COPY Dockerfile /opt/simplecontainergenerator_containers/backup_of_dockerfile/Dockerfile"))
    #
    push!(step_list_vector, DockerOnlyLine("ENTRYPOINT [\"/bin/bash\", \"-c\"]"))

    result = Template(FileList(file_list_vector),
                      StepList(step_list_vector))
    return result
end
