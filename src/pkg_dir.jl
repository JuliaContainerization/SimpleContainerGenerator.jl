function pkg_dir_simplecontainergenerator()::String
    this_file = @__FILE__ # PACKAGE_ROOT/src/pkg_dir.jl
    src_directory = dirname(this_file) # PACKAGE_ROOT/src
    package_root = dirname(src_directory) # PACKAGE_ROOT
    return package_root
end
