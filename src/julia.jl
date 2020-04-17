@inline function _get_julia_url(config::Config)
    return _get_julia_url(config.julia_version)
end

@inline function _get_julia_url(version::AbstractString)
    if version == "nightly"
        julia_url = "https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz"
        asc_url = "$(julia_url).asc"
        return julia_url, asc_url
    else
        return _get_julia_url(VersionNumber(version))
    end
end

@inline function _get_julia_url(version::VersionNumber)
    major = version.major
    minor = version.minor
    patch = version.patch
    julia_url = "https://julialang-s3.julialang.org/bin/linux/x64/$(major).$(minor)/julia-$(major).$(minor).$(patch)-linux-x86_64.tar.gz"
    asc_url = "$(julia_url).asc"
    return julia_url, asc_url
end
