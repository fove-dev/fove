--!strict

local test = require("@std/test")
local Fove = require("../src")
local Ownership = require("../src/core/internal/ownership")

local signal = Fove.signal
local effect = Fove.effect

test.case("owners dispose owned effects", function(asserts)
	local owner = Ownership.create()

	local value, setValue = signal(0)
	local runs = 0

	Ownership.run(owner, function()
		effect(function()
			value()
			runs += 1
		end)
	end)

	asserts.eq(runs, 1)

	setValue(1)
	asserts.eq(runs, 2)

	Ownership.dispose(owner)

	setValue(2)
	asserts.eq(runs, 2)
end)