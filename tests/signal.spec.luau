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

test.case("signal supports optional values", function(asserts)
	type User = {
		name: string,
	}

	local user, setUser = signal(nil :: User?)

	asserts.eq(user(), nil)

	local estatic: User = {
		name = "Estatic",
	}

	setUser(estatic)

	asserts.eq(user(), estatic)

	setUser(nil)

	asserts.eq(user(), nil)
end)