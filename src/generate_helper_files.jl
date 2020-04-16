@inline function _generate_julia_command(use_sysimage::Bool)
    if use_sysimage
        return "/opt/bin/julia -J/opt/stopgapcontainers/sysimage/SimpleContainerGeneratorSysimage.so"
    else
        return "/opt/bin/julia"
    end
end

@inline function _generate_do_not_use_sysimage_stopgap_julia_script_content(config::Config = Config())
    return _generate_stopgap_julia_script_content(false, config)
end

@inline function _generate_use_sysimage_stopgap_julia_script_content(config::Config = Config())
    make_sysimage = config.make_sysimage
    return _generate_stopgap_julia_script_content(make_sysimage, config)
end

@inline function _generate_stopgap_julia_script_content(use_sysimage::Bool,
                                                        config::Config = Config())
    julia_command = _generate_julia_command(use_sysimage)
    wrapper_script_env_vars = config.wrapper_script_env_vars
    set_wrapper_script_env_vars_string = ""
    for (name, value) in wrapper_script_env_vars
        set_wrapper_script_env_vars_string *= "export $(name)=\"$(value)\"\n"
    end
    return string("$(set_wrapper_script_env_vars_string)",
                  "export JULIA_DEPOT_PATH=\"/opt/stopgapcontainers/julia_depot\"\n",
                  "export JULIA_PROJECT=\"/opt/stopgapcontainers/julia_project\"\n",
                  "$(julia_command) \"\$@\"\n")
end

@inline function _generate_global_startup_file_content(config::Config = Config())
    return string("_stopgapcontainers_temp_depot_tmpdir = mktempdir()\n",
                  "atexit(() -> rm(_stopgapcontainers_temp_depot_tmpdir; force = true, recursive = true))\n",
                  "_stopgapcontainers_temp_depot = joinpath(_stopgapcontainers_temp_depot_tmpdir, \"stopgapcontainers_temp_depot\")\n",
                  "mkpath(_stopgapcontainers_temp_depot)\n",
                  "pushfirst!(Base.DEPOT_PATH, \"/opt/stopgapcontainers/julia_depot\")\n",
                  "if get(ENV, \"STOPGAP_CONTAINER_NO_TEMP_DEPOT\", \"\") != \"true\"\n",
                  "pushfirst!(Base.DEPOT_PATH, _stopgapcontainers_temp_depot)\n",
                  "end\n")
end
