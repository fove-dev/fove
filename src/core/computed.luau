--!strict

local Context = require("./internal/context")
local Graph = require("./internal/graph")
local Types = require("./internal/types")

type Source = Types.Source
type Observer = Types.Observer

type ComputedNode = Source & Observer

local function computed<T>(callback: () -> T): () -> T
	
    local dirty = true
	local value: T? = nil

	local node: ComputedNode

	local function invalidate(): ()
		
        if dirty then return end

		dirty = true
		Graph.notify(node)
	end

	node = {
		subscribers = {},
		dependencies = {},
		invalidate = invalidate,
	}

	local function recompute(): T
		
        Graph.detach(node)

		local previous = Context.setObserver(node)
		local success, result = pcall(callback)

		Context.setObserver(previous)

		if not success then
			Graph.detach(node)
			error(result, 0)
		end

		value = result
		dirty = false

		return result
	end

	local function get(): T
		
        Graph.track(node)

		if dirty then return recompute() end

		return value:: T
	end

	return get
end

return computed