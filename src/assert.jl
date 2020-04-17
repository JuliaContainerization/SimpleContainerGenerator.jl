@inline function always_assert(condition::Bool,
                               msg::String)
    if !condition
        throw(AlwaysAssertionError(msg))
    end
    return nothing
end
