function _convert_step_to_docker_commands(template::Template,
                                          step::PlaceholderDockerCopyFiles)::Vector{String}
    commands = String[]
    for i = 1:length(template.files.list)
        file = template.files.list[i]
        outside_src_full_path = "simplecontainergenerator_container_files/file_$(i)/$(file.dest_filename)"
        inside_dest_full_path = file.dest_full_path
        inside_dest_dir = file.dest_dir
        push!(commands, "RUN mkdir -p $(inside_dest_dir)")
        push!(commands, "COPY $(outside_src_full_path) $(inside_dest_full_path)")
    end
    return commands
end

function _convert_step_to_docker_commands(template::Template,
                                          step::DockerOnlyLine)::Vector{String}
    return String[step.full_contents]
end

function _convert_step_to_docker_commands(template::Template,
                                          step::RunStep)::Vector{String}
    return String["RUN $(step.command)"]
end

function _convert_step_to_docker_commands(template::Template,
                                          step::EnvStep)::Vector{String}
    return String["ENV $(step.name)=$(step.value)"]
end

# function _convert_step_to_docker_commands(template::Template,
#                                           step::AptStep)::Vector{String}
#     return String["RUN $(step.command)"]
# end

function _convert_step_to_docker_commands(template::Template,
                                          step::PlaceholderYumStep)::Vector{String}
    return String[]
end

function _docker_expand_template(template::Template)::String
    dockerfile_lines = String[]
    for step in template.steps.list
        lines_to_add::Vector{String} = _convert_step_to_docker_commands(template,
                                                                        step)::Vector{String}
        append!(dockerfile_lines, lines_to_add)
    end
    dockerfile_content = join(dockerfile_lines, "\n") * "\n"
    return dockerfile_content
end

function _write_all_docker_files(template::Template;
                                 output_directory::AbstractString)
    dockerfile_output_path = joinpath(output_directory, "Dockerfile")
    simplecontainergenerator_container_files_output_path = joinpath(output_directory, "simplecontainergenerator_container_files")

    dockerfile_content = _docker_expand_template(template)

    rm(dockerfile_output_path;
       force = true,
       recursive = true)
    mkpath(output_directory)
    open(dockerfile_output_path, "w") do io
        println(io, dockerfile_content)
    end
    @debug("Wrote file: \"$(dockerfile_output_path)\"")

    rm(simplecontainergenerator_container_files_output_path;
       force = true,
       recursive = true)
    mkpath(simplecontainergenerator_container_files_output_path)
    for i = 1:length(template.files.list)
        file = template.files.list[i]
        file_contents = file.contents
        file_output_path = joinpath(simplecontainergenerator_container_files_output_path,
                                    "file_$(i)",
                                    "$(file.dest_filename)")
        mkpath(dirname(file_output_path))
        open(file_output_path, "w") do io
            println(io, file_contents)
        end
        @debug("Wrote file: \"$(file_output_path)\"")
    end

    return output_directory
end
