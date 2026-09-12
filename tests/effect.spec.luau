--!strict

local test = require("@std/test")
local Fove = require("../src")
local Context = require("../src/core/internal/context")

local signal = Fove.signal
local effect = Fove.effect

test.case("effect runs immediately", function(asserts)
	local runs = 0

	effect(function()
		runs += 1
	end)

	asserts.eq(runs, 1)
end)

test.case("effect reacts to signal updates", function(asserts)
	local value, setValue = signal(0)
	local observed = -1

	effect(function()
		observed = value()
	end)

	asserts.eq(observed, 0)

	setValue(10)

	asserts.eq(observed, 10)
end)

test.case("effect ignores unrelated signals", function(asserts)
	local first, setFirst = signal(0)
	local _, setSecond = signal(0)

	local runs = 0

	effect(function()
		first()
		runs += 1
	end)

	asserts.eq(runs, 1)

	setSecond(1)

	asserts.eq(runs, 1)

	setFirst(1)

	asserts.eq(runs, 2)
end)

test.case("effect does not rerun when signal value is unchanged", function(asserts)
	local value, setValue = signal(10)

	local runs = 0

	effect(function()
		value()
		runs += 1
	end)

	asserts.eq(runs, 1)

	setValue(10)

	asserts.eq(runs, 1)
end)

test.case("effect tracks multiple signals", function(asserts)
	local a, setA = signal(1)
	local b, setB = signal(2)

	local result = 0

	effect(function()
		result = a() + b()
	end)

	asserts.eq(result, 3)

	setA(10)

	asserts.eq(result, 12)

	setB(20)

	asserts.eq(result, 30)
end)

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