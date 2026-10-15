--!strict

local queue = {}
local queued = {}
local flushing = false
local batchDepth = 0

local Scheduler = {}

function Scheduler.enqueue(callback: () -> ()): ()
	
    if queued[callback] then return end

	queued[callback] = true
	table.insert(queue, callback)

	if flushing or batchDepth > 0 then return end

	Scheduler.flush()
end

function Scheduler.flush(): ()
	
    if flushing or batchDepth > 0 then return end
	flushing = true

	local failed: boolean = false
	local firstError: any = nil
	local index = 1

	while index <= #queue do
		
		local callback = queue[index]
		queued[callback] = nil

		local success, err = pcall(callback)
		if not (success or failed) then
			failed = true
			firstError = firstError or err
		end

		index += 1
	end

	table.clear(queue)
	table.clear(queued)
	flushing = false

	if not failed then return end

    error(firstError, 0)
end

function Scheduler.beginBatch(): ()

    batchDepth += 1
end

function Scheduler.endBatch(): ()
	
    if batchDepth == 0 then error("cannot end a batch that was not started", 2) end
	batchDepth -= 1

	if batchDepth ~= 0 then return end

    Scheduler.flush()
end

return Scheduler