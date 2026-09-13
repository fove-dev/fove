--!strict

local Ownership = require("./internal/ownership")
local Context = require("./internal/context")
local Graph = require("./internal/graph")
local Types = require("./internal/types")

type Observer = Types.Observer

local function effect(callback: () -> ()): () -> ()
	
    local disposed = false
	local observer: Observer? = nil

	local function run(): ()
		
        if disposed then return end

		local currentObserver = observer
		if currentObserver == nil then return end

		Graph.detach(currentObserver)

		local previous = Context.setObserver(currentObserver)
		local success, err = pcall(function(): string? callback(); return end)

		Context.setObserver(previous)
		if success then return end

        Graph.detach(currentObserver)
		disposed = true

        error(err, 0)
	end

	observer = {
		dependencies = {},
		invalidate = run,
	}

	local function dispose(): ()
		
		if disposed then return end

		disposed = true
		Graph.detach(observer :: Observer)
	end

	Ownership.register(dispose)

	run()

	return dispose
end

return effect