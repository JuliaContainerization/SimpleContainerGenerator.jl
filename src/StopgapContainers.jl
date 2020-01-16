module StopgapContainers

import Pkg

export stopgap_docker

include("types.jl")

include("public.jl")

include("default_values.jl")
include("docker.jl")
include("helper_files.jl")
include("install_packages.jl")
include("julia.jl")
include("packagecompiler.jl")
include("precompile.jl")
include("utils.jl")

end # module
