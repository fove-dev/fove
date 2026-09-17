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