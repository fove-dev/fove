--!strict

local Types = require(`./types`)

type Observer = Types.Observer

local activeObserver: Observer? = nil

local Context = {}

function Context.getObserver(): Observer?
    
    return activeObserver
end

function Context.setObserver(observer: Observer?): Observer?
    
    local previous = activeObserver
    activeObserver = observer

    return previous
end

return Context