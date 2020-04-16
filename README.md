# SimpleContainerGenerator

[![Build Status](https://travis-ci.com/bcbi/SimpleContainerGenerator.jl.svg?branch=master)](https://travis-ci.com/bcbi/SimpleContainerGenerator.jl/branches)
[![Codecov](https://codecov.io/gh/bcbi/SimpleContainerGenerator.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/bcbi/SimpleContainerGenerator.jl)

SimpleContainerGenerator automates the process of creating container images for using Julia packages.

The Julia packages inside the container image are automatically compiled by [PackageCompiler](https://github.com/JuliaLang/PackageCompiler.jl) into a custom Julia system image (sysimage) for faster load times.

These container images are especially useful for using Julia packages on systems without Internet access. But they are not limited to that use case. You can use these container images anywhere, as long as you have access to a tool such as Docker, Singularity, etc.

When building the Docker images, make sure that Docker Desktop is set to use at least 4 GB of memory (RAM). If you run into errors, you should try further increasing the amount of available memory.

## Installation

```julia
import Pkg
Pkg.add("SimpleContainerGenerator")
```

## Examples

### Example 1

```
julia> import SimpleContainerGenerator

# Generate the Dockerfile and several helper files
julia> SimpleContainerGenerator.create_dockerfile("Example"; julia_version = v"1.4.0")

# Build the Docker image
julia> run(`docker build -t my_docker_username/my_image_name .`)

# Start a new container from the image
julia> run(`docker run --name my_container_name -it my_docker_username/my_image_name /bin/bash`)

# Now you are inside the Docker container
# To run Julia inside the container, use `julia` instead of julia

root@8fb7168c79f4:/# julia -e 'println("Hello world!")'
Hello world!
[]root@8fb7168c79f4:/# julia -e 'import Example; @show Example.domath(5)'

[]root@8fb7168c79f4:/# julia

# Now you are in an interactive Julia session inside the container

julia> println("Hello world!")

julia> import Example

julia> Example.domath(5)

julia> exit() # exit the Julia session inside the container
[]root@8fb7168c79f4:/# exit # exit the container
exit
Process(`docker run --name my_container_name -it my_docker_username/my_image_name /bin/bash`, ProcessExited(0))
```

### Example 2

```julia
julia> import SimpleContainerGenerator

# Generate the Dockerfile and several helper files
julia> SimpleContainerGenerator.create_dockerfile(["Foo", "Bar", "Baz"]; julia_version = v"1.4.0")

# Build the Docker image
julia> run(`docker build -t my_docker_username/my_image_name .`)
```

### Example 3

```julia
julia> import SimpleContainerGenerator

julia> pkgs = [(name = "Foo", version = "1.2.3"),
               (name = "Bar", version = "4.5.6"),
               (name = "Baz", version = "7.8.9")]

# Generate the Dockerfile and several helper files
julia> SimpleContainerGenerator.create_dockerfile(pkgs; julia_version = v"1.4.0")

# Build the Docker image
julia> run(`docker build -t my_docker_username/my_image_name .`)
```

### Example 4

```julia
julia> import SimpleContainerGenerator

julia> pkgs = [(name = "PredictMD",      rev = "master"),
               (name = "PredictMDExtra", rev = "master"),
               (name = "PredictMDFull",  rev = "master")]

# Generate the Dockerfile and several helper files
julia> SimpleContainerGenerator.create_dockerfile(pkgs; julia_version = v"1.4.0")

# Build the Docker image
julia> run(`docker build -t my_docker_username/my_image_name .`)
```

## Docker cheatsheet

| Command | Description |
| ------- | ----------- |
| `docker build -t my_docker_username/my_image_name .` | Build an image from a given `Dockerfile` |
| `docker run --name my_container_name -it my_docker_username/my_image_name /bin/bash` | Start a new container from a given image and enter a `bash` session |
| `docker run --name my_container_name -it -v /Users/MYUSERNAME/Desktop/MYFOLDER:/mount/MYFOLDER my_docker_username/my_image_name /bin/bash` | Start a new container from a given image, mount a local directory, and enter a `bash` session |
| `docker start -ai my_container_name` | Reenter a container after exiting it |
| `docker container rm -f my_container_name` | Delete a container |
| `docker login` | Login to Docker Hub |
| `docker push my_docker_username/my_image_name` | Push an image to Docker Hub |

## Related Packages
1. [PackageCompiler.jl](https://github.com/JuliaLang/PackageCompiler.jl)
2. [PackageCompilerX.jl](https://github.com/JuliaLang/PackageCompilerX.jl)

## Acknowledgements

- This work was supported in part by National Institutes of Health grants U54GM115677, R01LM011963, and R25MH116440. The content is solely the responsibility of the authors and does not necessarily represent the official views of the National Institutes of Health.
