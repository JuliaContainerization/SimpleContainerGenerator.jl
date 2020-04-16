@inline function _generate_julia_command(use_sysimage::Bool)
    if use_sysimage
        return "/opt/bin/julia -J/opt/simplecontainergenerator_containers/sysimage/SimpleContainerGeneratorSysimage.so"
    else
        return "/opt/bin/julia"
    end
end

@inline function _generate_do_not_use_sysimage_julia_script_content(config::Config = Config())
    return _generate_julia_script_content(false, config)
end

@inline function _generate_use_sysimage_julia_script_content(config::Config = Config())
    make_sysimage = config.make_sysimage
    return _generate_julia_script_content(make_sysimage, config)
end

@inline function _generate_julia_script_content(use_sysimage::Bool,
                                                        config::Config = Config())
    julia_command = _generate_julia_command(use_sysimage)
    wrapper_script_env_vars = config.wrapper_script_env_vars
    set_wrapper_script_env_vars_string = ""
    for (name, value) in wrapper_script_env_vars
        set_wrapper_script_env_vars_string *= "export $(name)=\"$(value)\"\n"
    end
    return string("$(set_wrapper_script_env_vars_string)",
                  "export JULIA_DEPOT_PATH=\"/opt/simplecontainergenerator_containers/julia_depot\"\n",
                  "export JULIA_PROJECT=\"/opt/simplecontainergenerator_containers/julia_project\"\n",
                  "$(julia_command) \"\$@\"\n")
end

@inline function _generate_global_startup_file_content(config::Config = Config())
    return string("_simplecontainergenerator_containers_temp_depot_tmpdir = mktempdir()\n",
                  "atexit(() -> rm(_simplecontainergenerator_containers_temp_depot_tmpdir; force = true, recursive = true))\n",
                  "_simplecontainergenerator_containers_temp_depot = joinpath(_simplecontainergenerator_containers_temp_depot_tmpdir, \"simplecontainergenerator_containers_temp_depot\")\n",
                  "mkpath(_simplecontainergenerator_containers_temp_depot)\n",
                  "pushfirst!(Base.DEPOT_PATH, \"/opt/simplecontainergenerator_containers/julia_depot\")\n",
                  "if get(ENV, \"SIMPLECONTAINERGENERATOR_CONTAINER_NO_TEMP_DEPOT\", \"\") != \"true\"\n",
                  "pushfirst!(Base.DEPOT_PATH, _simplecontainergenerator_containers_temp_depot)\n",
                  "end\n")
end
