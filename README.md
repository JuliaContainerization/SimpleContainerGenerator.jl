# SimpleContainerGenerator

[![Build Status](https://github.com/JuliaContainerization/SimpleContainerGenerator.jl/workflows/CI/badge.svg)](https://github.com/JuliaContainerization/SimpleContainerGenerator.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaContainerization/SimpleContainerGenerator.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaContainerization/SimpleContainerGenerator.jl)

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

In order to run these examples, you will need to have Docker installed on your computer.

### Example 1

```julia
import SimpleContainerGenerator

mkpath("my_image_name")
cd("my_image_name")

pkgs = [
    "Foo", # Replace Foo, Bar, Baz, etc. with the names of actual packages that you want to use
    "Bar",
    "Baz",
]
julia_version = v"1.4.0"

SimpleContainerGenerator.create_dockerfile(pkgs;
                                           julia_version = julia_version,
                                           output_directory = pwd())

run(`docker build -t my_docker_username/my_image_name .`)
```

### Example 2

```julia
import SimpleContainerGenerator

mkpath("my_image_name")
cd("my_image_name")

pkgs = [
    (name = "Foo",), # Replace Foo, Bar, Baz, etc. with the names of actual packages that you want to use
    (name = "Bar",),
    (name = "Baz",),
]
julia_version = v"1.4.0"

SimpleContainerGenerator.create_dockerfile(pkgs;
                                           julia_version = julia_version,
                                           output_directory = pwd())

run(`docker build -t my_docker_username/my_image_name .`)
```

### Example 3

```julia
import SimpleContainerGenerator

mkpath("my_image_name")
cd("my_image_name")

pkgs = [
    (name = "Foo", version = "1.2.3",), # Replace Foo, Bar, Baz, etc. with the names of actual packages that you want to use
    (name = "Bar", version = "4.5.6",), # and replace the version numbers with actual version numbers for the packages
    (name = "Baz", version = "7.8.9",),
]
julia_version = v"1.4.0"

SimpleContainerGenerator.create_dockerfile(pkgs;
                                           julia_version = julia_version,
                                           output_directory = pwd())

run(`docker build -t my_docker_username/my_image_name .`)
```

### Example 4

```julia
import SimpleContainerGenerator

mkpath("my_image_name")
cd("my_image_name")

pkgs = [
    (name = "Foo", version = "1.2.3",), # Replace Foo, Bar, Baz, etc. with the names of actual packages that you want to use
    (name = "Bar", version = "4.5.6",), # and replace the version numbers with actual version numbers for the packages
    (name = "Baz", rev     = "master",), # and replace "master" with the name of the branch you want to use
]
julia_version = v"1.4.0"

SimpleContainerGenerator.create_dockerfile(pkgs;
                                           julia_version = julia_version,
                                           output_directory = pwd())

run(`docker build -t my_docker_username/my_image_name .`)
```

### Example 5

```julia
import SimpleContainerGenerator

mkpath("my_image_name")
cd("my_image_name")

pkgs = [
    "Foo", # Replace Foo, Bar, Baz, etc. with the names of actual packages that you want to use
    "Bar",
    "Baz",
]
no_test = [
    "Foo", # Replace Foo, etc. with the names of actual packages
    ]
exclude_packages_from_sysimage = [
    "Bar", # Replace Bar, etc. with the names of actual packages
    ]
julia_version = v"1.4.0"

SimpleContainerGenerator.create_dockerfile(pkgs;
                                           julia_version = julia_version,
                                           no_test = no_test,
                                           exclude_packages_from_sysimage = exclude_packages_from_sysimage,
                                           output_directory = pwd())

run(`docker build -t my_docker_username/my_image_name .`)
```

### Example 6

```julia
import SimpleContainerGenerator

mkpath("my_image_name")
cd("my_image_name")

pkgs = [
    "Foo", # Replace Foo, Bar, Baz, etc. with the names of actual packages that you want to use
    "Bar",
    "Baz",
]
julia_version = v"1.4.0"
parent_image = "ubuntu:latest"

SimpleContainerGenerator.create_dockerfile(pkgs;
                                           julia_version = julia_version,
                                           output_directory = pwd(),
                                           parent_image = parent_image)

run(`docker build -t my_docker_username/my_image_name .`)
```

### Example 7

```julia
import SimpleContainerGenerator

mkpath("my_image_name")
cd("my_image_name")

pkgs = [
    "Foo", # Replace Foo, Bar, Baz, etc. with the names of actual packages that you want to use
    "Bar",
    "Baz",
]
julia_version = v"1.4.0"
parent_image = "nvidia/cuda:11.2.0-devel-ubuntu20.04"

SimpleContainerGenerator.create_dockerfile(pkgs;
                                           julia_version = julia_version,
                                           output_directory = pwd(),
                                           parent_image = parent_image)

run(`docker build -t my_docker_username/my_image_name .`)
```

### Example 8

```julia
import SimpleContainerGenerator

mkpath("my_image_name")
cd("my_image_name")

# Add private registries. General will always be included as a backup.
# The first method uses your ssh credentials, whereas the second requires a
# Personal Access Token.
registry_urls = ["git@github.com:MyCompany/MyPrivateRegistry.git",
                 "https://username:githubPAT@github.com/MyCompany/AnotherRegistry.git"]

# Optionally, override the URL of your privately registered package. Useful if your registry
# stores the URIs of your packages as git+ssh, but you wish to use PATs in your workflow.
pkgs = [
    (name = "Foo", url = "https://username:githubPAT@github.com/MyCompany/MyPackage.jl.git",),
    (name = "Bar", ),
    (name = "Baz", ),
]
julia_version = v"1.4.0"

SimpleContainerGenerator.create_dockerfile(pkgs;
                                           julia_version = julia_version,
                                           output_directory = pwd(),
                                           registry_urls = registry_urls,
                                           mount_ssh = true) # Only required if using the ssh method

# Note: you may need to `ssh-add` your key before this command will work.
run(`DOCKER_BUILDKIT=1 docker build --ssh default -t my_docker_username/my_image_name .`)
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

## Acknowledgements

- This work was supported in part by National Institutes of Health grants R01LM011963, R25MH116440, and U54GM115677 and National Science Foundation award 2027892. The content is solely the responsibility of the authors and does not necessarily represent the official views of the National Institutes of Health or the National Science Foundation.
