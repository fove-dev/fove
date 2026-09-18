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