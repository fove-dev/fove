--!strict

local Types = require(`./types`)

type Observer = Types.Observer
type Owner = Types.Owner

local activeObserver: Observer? = nil
local activeOwner: Owner? = nil

local Context = {}

function Context.getOwner(): Owner?
    
    return activeOwner
end

function Context.setOwner(owner: Owner?): Owner?
    
    local previous = activeOwner
    activeOwner = owner

    return previous
end

function Context.getObserver(): Observer?
    
    return activeObserver
end

function Context.setObserver(observer: Observer?): Observer?
    
    local previous = activeObserver
    activeObserver = observer

    return previous
end

return Context