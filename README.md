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

julia> run(`docker build -t my_docker_username/my_image_name .`)
```

### Example 2

```julia
julia> using StopgapContainers

julia> pkgs = [(name = "PredictMD",      rev = "master"),
               (name = "PredictMDExtra", rev = "master"),
               (name = "PredictMDFull",  rev = "master")]

julia> stopgap_docker(pkgs)

julia> run(`docker build -t my_docker_username/my_image_name .`)
```

## Useful Docker commands

Build an image from a given `Dockerfile`:
```bash
docker build -t my_docker_username/my_image_name .
```

Start a new container from a given image and enter a `bash` session:
```bash
docker run --name my_container_name -it my_docker_username/my_image_name /bin/bash
```

Reenter the same container after exiting it:
```bash
docker start -ai my_container_name
```

Delete the container:
```bash
docker container rm -f my_container_name
```

Login to Docker Hub:
```bash
docker login
```

Push an image to Docker Hub:
```bash
docker push my_docker_username/my_image_name
```
