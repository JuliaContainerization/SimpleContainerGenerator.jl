const _default_packagecompilerx_installation_command = "add https://github.com/KristofferC/PackageCompilerX.jl#master"

const _future_packagecompilerx_installation_command = "add PackageCompilerX"

const _default_julia_version = "nightly"

const _default_julia_cpu_target = "generic"

const _default_precompile_env_vars = Dict{String, String}("PREDICTMD_TEST_GROUP" => "all",
                                                          "PREDICTMD_TEST_PLOTS" => "true")

const _predictmd_apt = String[]

const _default_apt = String["apt-utils",
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
                            "zlib1g-dev"]
