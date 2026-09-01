--!strict

local test = require("@std/test")
local Fove = require("../src")

local signal = Fove.signal

test.case("signal stores its initial value", function(asserts)
	local value = signal(10)

	asserts.eq(10, value())
end)

test.case("signal updates its value", function(asserts)
	local value, setValue = signal(10)

	setValue(20)

	asserts.eq(20, value())
end)

test.case("signal supports booleans", function(asserts)
	local value, setValue = signal(false)

	asserts.eq(false, value())

	setValue(true)

	asserts.eq(true, value())
end)

test.case("signal supports tables", function(asserts)
	local initial = {
		name = "Fove",
	}

	local value, setValue = signal(initial)

	asserts.eq(initial, value())

	local newValue = {
		name = "Fove 2",
	}

	setValue(newValue)

	asserts.eq(newValue, value())
end)