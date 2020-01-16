# StopgapContainers

[![Build Status](https://travis-ci.com/bcbi/StopgapContainers.jl.svg?branch=master)](https://travis-ci.com/bcbi/StopgapContainers.jl/branches)
[![Codecov](https://codecov.io/gh/bcbi/StopgapContainers.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/bcbi/StopgapContainers.jl)

## Installation

```julia
import Pkg
Pkg.add(Pkg.PackageSpec(url = "https://github.com/bcbi/StopgapContainers.jl", rev = "master"))
```

## Examples

### Example 1

```julia
julia> using StopgapContainers

julia> stopgap_docker("Crayons")

julia> run(`docker build -t my_docker_image_name .`)
```

### Example 2

```julia
julia> using StopgapContainers

julia> pkgs = [(name = "PredictMD",      rev = "master"),
               (name = "PredictMDExtra", rev = "master"),
               (name = "PredictMDFull",  rev = "master")]

julia> stopgap_docker(pkgs)

julia> run(`docker build -t my_docker_image_name .`)
```
