--!strict

local Ownership = require(`../core/internal/ownership`)
local Context = require(`./internal/context`)

export type Root = {
	destroy: (self: Root) -> (),
}

local function mount(target: Instance, callback: () -> ()): Root
	
	local owner = Ownership.create()
	local root = {}:: Root

	function root:destroy(): ()

		Ownership.dispose(owner)
	end

	local previous = Context.setParent(target)
	local success, err = pcall(Ownership.run, owner, callback)

	Context.setParent(previous)

	if success then return root end

	pcall(Ownership.dispose, owner)
	error(err, 0)
end

return mount