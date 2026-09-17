--!strict

local test = require("@std/test")
local Fove = require("../src")

local onCleanup = Fove.onCleanup
local computed = Fove.computed
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

test.case("effects react to computed values", function(asserts)
	local value, setValue = signal(10)

	local doubled = computed(function()
		return value() * 2
	end)

	local observed = 0

	effect(function()
		observed = doubled()
	end)

	asserts.eq(observed, 20)

	setValue(20)

	asserts.eq(observed, 40)
end)

test.case("effect cleanup runs before rerun", function(asserts)
	local value, setValue = signal(0)
	local events = {}

	effect(function()
		local current = value()

		table.insert(events, `run {current}`)

		onCleanup(function()
			table.insert(events, `cleanup {current}`)
		end)
	end)

	setValue(1)

	asserts.eq(events[1], "run 0")
	asserts.eq(events[2], "cleanup 0")
	asserts.eq(events[3], "run 1")
end)

test.case("effect cleanup runs on disposal", function(asserts)
	local cleaned = false

	local dispose = effect(function()
		onCleanup(function()
			cleaned = true
		end)
	end)

	asserts.eq(cleaned, false)

	dispose()

	asserts.eq(cleaned, true)
end)