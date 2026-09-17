--!strict

local Context = require(`./internal/context`)
local Ownership = require(`./internal/ownership`)

local function onCleanup(callback: () -> ()): ()

	if Context.getOwner() == nil then error("onCleanup must be called within an owner", 2) end

	Ownership.register(callback)
end

return onCleanup