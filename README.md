# StopgapContainers

[![Build Status](https://travis-ci.com/bcbi/StopgapContainers.jl.svg?branch=master)](https://travis-ci.com/bcbi/StopgapContainers.jl)
[![Codecov](https://codecov.io/gh/bcbi/StopgapContainers.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/bcbi/StopgapContainers.jl)

## Installation

```julia
import Pkg
Pkg.add(Pkg.Types.PackageSpec(url = "https://github.com/bcbi/StopgapContainers.jl", rev = "master"))
```

## Example usage

```julia
julia> import Pkg: PackageSpec

julia> import StopgapContainers: stopgap_docker

julia> pkgs = [PackageSpec(name = "PredictMD", rev = "master"),
               PackageSpec(name = "PredictMDExtra", rev = "master"),
               PackageSpec(name = "PredictMDFull", rev = "master")]

julia> stopgap_docker(pkgs)

julia> run(`docker build -t my_docker_image_name .`)
```
