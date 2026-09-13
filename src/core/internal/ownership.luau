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

	owner.disposables[dispose] = true
end

function Ownership.dispose(owner: Owner): ()
	
    if owner.disposed then return end
	owner.disposed = true

	for dispose in owner.disposables do

        dispose()
    end

	table.clear(owner.disposables)
end

function Ownership.run(owner: Owner, callback: ()->()): ()
	
    local previous = Context.setOwner(owner)
	local success, result = pcall(function(): string? callback(); return end)

	Context.setOwner(previous)

	if success then return end

	error(result, 0)
end

return Ownership