--!strict

local Types = require(`./types`)
local Context = require(`./context`)

type Source = Types.Source

local Graph = {}

function Graph.track(source: Source): ()
    
    local observer = Context.getObserver()
    if observer == nil then return end

    source.subscribers[observer] = true
    observer.dependencies[source] = true
end

return Graph