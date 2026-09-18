--!strict

local Scheduler = require(`./internal/scheduler`)
local Graph = require(`./internal/graph`)
local Types = require(`./internal/types`)

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

        Scheduler.beginBatch()

        local success, err = pcall(function(): string? Graph.notify(source); return end)
        Scheduler.endBatch()

        if success then return end
        
        error(err, 0)
    end

    return get, set
end

return signal