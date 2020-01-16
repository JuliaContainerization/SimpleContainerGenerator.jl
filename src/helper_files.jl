function _generate_no_sysimage_stopgap_julia_script_content(config::Config = Config())
    return string("export JULIA_DEPOT_PATH=\"/opt/stopgapcontainers/julia_depot\"\n",
                  "export JULIA_PROJECT=\"/opt/stopgapcontainers/julia_project\"\n",
                  "/usr/bin/julia \"\$@\"\n")
end

function _generate_stopgap_julia_script_content(config::Config = Config())
    return string("export JULIA_DEPOT_PATH=\"/opt/stopgapcontainers/julia_depot\"\n",
                  "export JULIA_PROJECT=\"/opt/stopgapcontainers/julia_project\"\n",
                  "/usr/bin/julia -J/opt/stopgapcontainers/sysimage/StopgapContainersSysimage.so \"\$@\"\n")
end

function _generate_global_startup_file_content(config::Config = Config())
    return string("_stopgapcontainers_temp_depot_tmpdir = mktempdir()\n",
                  "atexit(() -> rm(_stopgapcontainers_temp_depot_tmpdir; force = true, recursive = true))\n",
                  "_stopgapcontainers_temp_depot = joinpath(_stopgapcontainers_temp_depot_tmpdir, \"stopgapcontainers_temp_depot\")\n",
                  "mkpath(_stopgapcontainers_temp_depot)\n",
                  "pushfirst!(Base.DEPOT_PATH, \"/opt/stopgapcontainers/julia_depot\")\n",
                  "if get(ENV, \"STOPGAP_CONTAINER_NO_TEMP_DEPOT\", \"\") != \"true\"\n",
                  "pushfirst!(Base.DEPOT_PATH, _stopgapcontainers_temp_depot)\n",
                  "end\n")
end
