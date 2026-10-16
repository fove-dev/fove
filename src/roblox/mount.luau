--!strict

local Ownership = require(`../core/internal/ownership`)

export type Root = {
	destroy: (self: Root) -> (),
}

local function mount(_target: Instance, callback: () -> ()): Root
	
	local owner = Ownership.create()
	local root = {}:: Root

	function root:destroy(): ()

		Ownership.dispose(owner)
	end

	local success, err = pcall(Ownership.run, owner, callback)
	if success then return root end

	pcall(Ownership.dispose, owner)
	error(err, 0)
end

return mount