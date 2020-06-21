# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Assertions

struct AlwaysAssertionError <: Exception
    msg::String
end

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Steps

abstract type AbstractStep end

struct DockerOnlyLine <: AbstractStep
    full_contents::String
end

struct PlaceholderDockerCopyFiles <: AbstractStep
end

struct RunStep <: AbstractStep
    command::String
end

struct EnvStep <: AbstractStep
    name::String
    value::String
end

struct AptStep <: AbstractStep
    command::String
end

struct PlaceholderYumStep <: AbstractStep
end

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Step list

struct StepList
    list::Vector{AbstractStep}
end

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Files

struct File
    contents::String
    dest_dir::String
    dest_filename::String
    dest_full_path::String
end

function File(contents::String,
              dest_dir::String,
              dest_filename::String)
    dest_full_path = string(dest_dir,
                            "/",
                            dest_filename)
    result = File(contents,
                  dest_dir,
                  dest_filename,
                  dest_full_path)
    return result
end

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# File plan

struct FileList
    list::Vector{File}
end

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Template

struct Template
    files::FileList
    steps::StepList
end

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
