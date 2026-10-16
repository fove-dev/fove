--!strict

local Scheduler = require(`./internal/scheduler`)

local function batch(callback: () -> ()): ()
	
    Scheduler.beginBatch()

	local success, err = pcall(callback)

	Scheduler.endBatch()
	if success then return end

    error(err, 0)
end

return batch