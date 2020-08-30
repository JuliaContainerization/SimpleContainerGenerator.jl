function _generate_backupsofsimplecontainergenerator_content_1(config::Config)
    simplecontainergenerator_installation_command = config.simplecontainergenerator_installation_command
    lines = String[
        "empty!(Base.DEPOT_PATH)",
        "pushfirst!(Base.DEPOT_PATH, \"/opt/simplecontainergenerator_containers/depot_backup_simplecontainergenerator\")",
        "import Pkg",
        "$(simplecontainergenerator_installation_command)",
    ]
    content = join(lines, "\n") * "\n"
    return content
end

function _generate_backupsofsimplecontainergenerator_content_2(config::Config)
    packagecompiler_installation_command = config.packagecompiler_installation_command
    lines = String[
        "empty!(Base.DEPOT_PATH)",
        "pushfirst!(Base.DEPOT_PATH, \"/opt/simplecontainergenerator_containers/depot_backup_packagecompiler\")",
        "import Pkg",
        "$(packagecompiler_installation_command)",
    ]
    content = join(lines, "\n") * "\n"
    return content
end
