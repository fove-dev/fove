--!strict

local activeParent: Instance? = nil

local Context = {}

function Context.getParent(): Instance?
    
    return activeParent
end

function Context.setParent(parent: Instance?): Instance?

    local previous = activeParent
    activeParent = parent

    return previous
end

return Context