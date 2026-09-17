--!strict

local Ownership = require("./internal/ownership")
local Context = require("./internal/context")
local Graph = require("./internal/graph")
local Types = require("./internal/types")

type Observer = Types.Observer
type Owner = Types.Owner

local function effect(callback: () -> ()): () -> ()
	
	local disposed = false
	local runOwner: Owner? = nil
	local observer: Observer? = nil

	local function disposeRunOwner(): ()
		
		if runOwner == nil then return end

		Ownership.dispose(runOwner)
		runOwner = nil
	end

	local function run(): ()
		
		if disposed then return end

		local currentObserver = observer
		if currentObserver == nil then return end

		Graph.detach(currentObserver)
		disposeRunOwner()

		runOwner = Ownership.create()

		local previous = Context.setObserver(currentObserver)

		local success, err = pcall(function(): string? Ownership.run(runOwner :: Owner, callback); return end)

		Context.setObserver(previous)

		if success then return end

		Graph.detach(currentObserver)
		disposeRunOwner()

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
		disposeRunOwner()
	end

	Ownership.register(dispose)

	run()

	return dispose
end

return effect