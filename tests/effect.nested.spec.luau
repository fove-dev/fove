--!strict

local test = require(`@std/test`)
local Fove = require(`../src`)

local onCleanup = Fove.onCleanup
local signal = Fove.signal
local effect = Fove.effect

test.case("nested effects are disposed before parent reruns", function(asserts)
	local outer, setOuter = signal(0)
	local inner, setInner = signal(0)

	local outerRuns = 0
	local innerRuns = 0

	effect(function()
		outer()
		outerRuns += 1

		effect(function()
			inner()
			innerRuns += 1
		end)
	end)

	asserts.eq(outerRuns, 1)
	asserts.eq(innerRuns, 1)

	setInner(1)

	asserts.eq(outerRuns, 1)
	asserts.eq(innerRuns, 2)

	setOuter(1)

	asserts.eq(outerRuns, 2)
	asserts.eq(innerRuns, 3)

	setInner(2)

	asserts.eq(outerRuns, 2)
	asserts.eq(innerRuns, 4)
end)

test.case("nested effects are removed when their branch disappears", function(asserts)
	local enabled, setEnabled = signal(true)
	local value, setValue = signal(0)

	local runs = 0

	effect(function()
		if enabled() then
			effect(function()
				value()
				runs += 1
			end)
		end
	end)

	asserts.eq(runs, 1)

	setValue(1)
	asserts.eq(runs, 2)

	setEnabled(false)

	setValue(2)

	asserts.eq(runs, 2)
end)

test.case("nested effect cleanup runs when parent reruns", function(asserts)
	local value, setValue = signal(0)

	local cleanups = 0

	effect(function()
		value()

		effect(function()
			onCleanup(function()
				cleanups += 1
			end)
		end)
	end)

	asserts.eq(cleanups, 0)

	setValue(1)

	asserts.eq(cleanups, 1)
end)