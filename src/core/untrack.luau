--!strict

local Context = require(`./internal/context`)

local function untrack<T>(callback: () -> T): T
	
    local previous = Context.setObserver(nil)

	local success, result = pcall(callback)

	Context.setObserver(previous)

	if not success then error(result, 0) end

	return result
end

return untrack