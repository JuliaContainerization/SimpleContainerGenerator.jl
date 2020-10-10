import PackageCompiler

_default_docker_parent_image() = "ubuntu:latest"

_default_julia_version() = v"1.4.0"

_default_packagecompiler_installation_command() = "import Pkg; Pkg.add(Pkg.PackageSpec(name = \"PackageCompiler\", version = \"1.2.2 - 1\"));"

_default_simplecontainergenerator_installation_command() = "import Pkg; Pkg.add(Pkg.PackageSpec(name = \"SimpleContainerGenerator\"));"

_default_julia_cpu_target() = "$(PackageCompiler.default_app_cpu_target());$(PackageCompiler.NATIVE_CPU_TARGET)"
_recommended_julia_cpu_target() = "$(PackageCompiler.default_app_cpu_target());$(PackageCompiler.NATIVE_CPU_TARGET)"
_fastest_nonportable_julia_cpu_target() = "$(PackageCompiler.NATIVE_CPU_TARGET)"

 _default_precompile_execution_env_vars() = Dict{String, String}(
    "PREDICTMD_TEST_GROUP" => "all",
    "PREDICTMD_TEST_PLOTS" => "true"
)

_default_wrapper_script_env_vars() = Dict{String, String}(
    "PREDICTMD_TEST_GROUP" => "all",
    "PREDICTMD_TEST_PLOTS" => "true",
    "GKSwstype" => "100"
)

_predictmd_apt() = String[]

_default_apt() = String[
    "apt-utils",
    "build-essential",
    "bzip2",
    "ca-certificates",
    "cmake",
    "coreutils",
    "curl",
    "emacs ",
    "emacs nano vim",
    "fonts-liberation",
    "gettext",
    "gfortran",
    "git",
    "git-all",
    "git-flow",
    "git-lfs",
    "gnupg",
    "gpg",
    "gpg-agent",
    "gzip",
    "hdf5-tools",
    "libcurl4-openssl-dev",
    "libgconf-2-4",
    "libgtk2.0-0",
    "libnss3",
    "libpgf-dev",
    "libpgf6",
    "libpgf6-dbg",
    "libpng-dev",
    "libssl-dev",
    "libxss1",
    "libxtst6",
    "locales",
    "lsb-release",
    "m4",
    "nano",
    "openssh-client",
    "openssl",
    "pdf2svg",
    "poppler-utils",
    "qt5-default",
    "screen",
    "sudo",
    "texlive-binaries",
    "texlive-latex-base",
    "texlive-latex-extra",
    "texlive-luatex",
    "texlive-pictures",
    "tmux ",
    "tree",
    "unzip",
    "vim",
    "wget",
    "xdg-utils",
    "zip",
    "zlib1g-dev",
]
