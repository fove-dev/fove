--!strict

local test = require(`@std/test`)
local Fove = require(`../src`)
local Context = require(`../src/core/internal/context`)

local onCleanup = Fove.onCleanup
local signal = Fove.signal
local effect = Fove.effect

test.case("disposed effects stop reacting", function(asserts)
	local value, setValue = signal(0)

	local runs = 0

	local dispose = effect(function()
		value()
		runs += 1
	end)

	asserts.eq(runs, 1)

	setValue(1)

	asserts.eq(runs, 2)

	dispose()

	setValue(2)

	asserts.eq(runs, 2)
end)

test.case("effect restores observer context after errors", function(asserts)
	local success = pcall(function()
		effect(function()
			error("oops")
		end)
	end)

	asserts.eq(success, false)
	asserts.eq(Context.getObserver(), nil)
end)

test.case("failed effects do not remain subscribed", function(asserts)
	local value, setValue = signal(0)
	local runs = 0

	pcall(function()
		effect(function()
			value()
			runs += 1
			error("oops")
		end)
	end)

	asserts.eq(runs, 1)

	pcall(function()
		setValue(1)
	end)

	asserts.eq(runs, 1)
end)

test.case("failed effects dispose their run owner", function(asserts)
	local trigger, setTrigger = signal(false)

	local runs = 0
	local cleanups = 0

	effect(function()
		runs += 1

		if trigger() then
			onCleanup(function()
				cleanups += 1
			end)

			error("oops")
		end
	end)

	asserts.eq(runs, 1)
	asserts.eq(cleanups, 0)

	local success = pcall(function()
		setTrigger(true)
	end)

	asserts.eq(success, false)
	asserts.eq(runs, 2)
	asserts.eq(cleanups, 1)

	setTrigger(false)

	asserts.eq(runs, 2)
	asserts.eq(cleanups, 1)
end)