function _get_julia_url(config::Config)
    return _get_julia_url(config.julia_version)
end

function _get_julia_url(version::AbstractString)
    if version == "nightly"
        return "https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz"
    else
        return "https://julialang-s3.julialang.org/bin/linux/x64/$(version)/julia-$(version)-latest-linux-x86_64.tar.gz"
    end
end
