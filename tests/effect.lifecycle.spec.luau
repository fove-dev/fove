--!strict

local test = require("@std/test")
local Fove = require("../src")
local Context = require("../src/core/internal/context")

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