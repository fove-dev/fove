--!strict

local Types = require(`./internal/types`)
local Graph = require(`./internal/graph`)

type Source = Types.Source

local function signal<T>(initialValue: T): (()->T, (T)->()) 
    
    local value = initialValue

    local source: Source = {
        subscribers = {},
    }

    local function get(): T
        
        Graph.track(source)

        return value
    end

    local function set(newValue: T): ()
        
        if value == newValue then return end

        value = newValue

        -- maybe notify?
    end

    return get, set
end

return signal