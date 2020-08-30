import Pkg

function _generate_packagecompiler_install_content(config::Config)
    packagecompiler_installation_command = config.packagecompiler_installation_command
    lines = String[
        "empty!(Base.DEPOT_PATH)",
        "pushfirst!(Base.DEPOT_PATH, \"/opt/simplecontainergenerator_containers/packagecompiler_depot\")",
        "import Pkg",
        "$(packagecompiler_installation_command)",
    ]
    content = join(lines, "\n") * "\n"
    return content
end
