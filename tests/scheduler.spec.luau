--!strict

local test = require(`@std/test`)
local Fove = require(`../src`)

local effect = Fove.effect
local signal = Fove.signal

test.case("scheduler deduplicates queued effects", function(asserts)
	local a, setA = signal(0)
	local b, setB = signal(0)

	local runs = 0

	effect(function()
		a()
		b()
		runs += 1
	end)

	asserts.eq(runs, 1)

	setA(1)
	setB(1)

    asserts.eq(runs, 3)
end)

test.case("scheduler recovers after effect errors", function(asserts)
	local first, setFirst = signal(0)
	local second, setSecond = signal(0)

	local secondRuns = 0

	effect(function()
		if first() == 1 then
			error("oops")
		end
	end)

	effect(function()
		second()
		secondRuns += 1
	end)

	local success = pcall(function()
		setFirst(1)
	end)

	asserts.eq(success, false)

	setSecond(1)

	asserts.eq(secondRuns, 2)
end)

test.case("scheduler continues after callback errors", function(asserts)
    local Scheduler = require(`../src/core/internal/scheduler`)
    local order = {}

    Scheduler.beginBatch()

    Scheduler.enqueue(function()
        table.insert(order, "first")
    end)

    Scheduler.enqueue(function()
        table.insert(order, "failing")
        error("oops")
    end)

    Scheduler.enqueue(function()
        table.insert(order, "last")
    end)

    local success = pcall(Scheduler.endBatch)

    asserts.eq(success, false)
    asserts.eq(#order, 3)
    asserts.eq(order[1], "first")
    asserts.eq(order[2], "failing")
    asserts.eq(order[3], "last")

    local recovered = false

    Scheduler.enqueue(function()
        recovered = true
    end)

    asserts.eq(recovered, true)
end)

test.case("scheduler detects infinite reactive updates", function(asserts)
    local count, setCount = signal(0)
    local runs = 0

    local success, err = pcall(function()
        effect(function()
            local current = count()
            runs += 1

            -- prevents from crashing if the protection fails
            if runs > 2000 then
                error("test safety limit reached")
            end

            setCount(current + 1)
        end)
    end)

    asserts.eq(success, false)
    asserts.eq(string.find(tostring(err), "reactive update loop", 1, true) ~= nil, true)

	local other, setOther = signal(0)
	local otherRuns = 0

	effect(function()
		other()
		otherRuns += 1
	end)

	setOther(1)

	asserts.eq(otherRuns, 2)
	asserts.eq(runs < 2000, true)
end)

test.case("scheduler allows finite reactive updates", function(asserts)
    local count, setCount = signal(0)
    local runs = 0

    effect(function()
        local current = count()
        runs += 1

        if current < 5 then
            setCount(current + 1)
        end
    end)

    asserts.eq(count(), 5)
    asserts.eq(runs, 6)
end)