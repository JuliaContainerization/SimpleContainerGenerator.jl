module SimpleContainerGenerator

import PackageCompiler
import Pkg
import UUIDs

include("types_config.jl")
include("types.jl")

include("public.jl")

include("public_create_dockerfile.jl")

include("assert.jl")
include("backups_of_simplecontainergenerator.jl")
include("config_to_template.jl")
include("default_values.jl")
include("docker.jl")
include("generate_helper_files.jl")
include("generate_install_packages.jl")
include("generate_packagecompiler_install.jl")
include("generate_packagecompiler_run.jl")
include("generate_precompile_execution.jl")
include("julia.jl")
include("utils.jl")

end # module
