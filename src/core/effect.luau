--!strict

local Ownership = require(`./internal/ownership`)
local Scheduler = require(`./internal/scheduler`)
local Context = require(`./internal/context`)
local Graph = require(`./internal/graph`)
local Types = require(`./internal/types`)

type Observer = Types.Observer
type Owner = Types.Owner

local function effect(callback: () -> ()): () -> ()
	
	local disposed = false
	local runOwner: Owner? = nil
	local observer: Observer? = nil

	local function disposeRunOwner(): ()
		
		local owner = runOwner
		if owner == nil then return end

		runOwner = nil
		Ownership.dispose(owner)
	end

	local function run(): ()
		
		if disposed then return end

		local currentObserver = observer
		if currentObserver == nil then return end

		Graph.detach(currentObserver)

		local cleanupSuccess, cleanupErr = pcall(function(): string? disposeRunOwner(); return end)
		if not cleanupSuccess then
			disposed = true
			error(cleanupErr, 0)
		end
		
		if disposed then return end

		runOwner = Ownership.create()

		local previous = Context.setObserver(currentObserver)
		local success, err = pcall(function(): string? Ownership.run(runOwner:: Owner, callback); return end)

		Context.setObserver(previous)

		if disposed or not success then Graph.detach(currentObserver) end
		if success then return end

		disposed = true

		pcall(disposeRunOwner)
		error(err, 0)
	end

	observer = {
		dependencies = {},
		invalidate = function() Scheduler.enqueue(run) end,
	}

	local function dispose(): ()
		
		if disposed then return end
		disposed = true

		Graph.detach(observer:: Observer)
		disposeRunOwner()
	end

	Ownership.register(dispose)
	Scheduler.beginBatch()

	local success, err = pcall(function(): string? run(); return end)
	local flushSuccess, flushErr = pcall(function(): string? Scheduler.endBatch(); return end)

	if not (success and flushSuccess) then
		pcall(dispose)
		error(if not success then err else flushErr, 0)
	end

	return dispose
end

return effect