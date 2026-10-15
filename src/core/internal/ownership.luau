--!strict

local Context = require(`./context`)
local Types = require(`./types`)

type Owner = Types.Owner

local Ownership = {}

function Ownership.create(): Owner
    
    return {
        disposables = {},
        disposed = false,
    }
end

function Ownership.register(dispose: () -> ()): ()
	
    local owner = Context.getOwner()
    if owner == nil then return end
	if owner.disposed then dispose(); return end

	table.insert(owner.disposables, dispose)
end

function Ownership.dispose(owner: Owner): ()
	
    if owner.disposed then return end
	owner.disposed = true

    local firstError: any = nil
    local failed: boolean = false

	for index = #owner.disposables, 1, -1 do

        local success, err = pcall(function(): string? owner.disposables[index](); return end)
        if success then continue end

        failed = true
        firstError = err
    end

	table.clear(owner.disposables)

    if not failed then return end

    error(firstError, 0)
end

function Ownership.run(owner: Owner, callback: ()->()): ()
	
    local previous = Context.setOwner(owner)
	local success, result = pcall(function(): string? callback(); return end)

	Context.setOwner(previous)

	if success then return end

	error(result, 0)
end

return Ownership