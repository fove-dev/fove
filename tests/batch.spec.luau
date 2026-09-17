--!strict

local test = require(`@std/test`)
local Fove = require(`../src`)

local effect = Fove.effect
local signal = Fove.signal
local batch = Fove.batch

test.case("batch deduplicates effect updates", function(asserts)
	local a, setA = signal(0)
	local b, setB = signal(0)

	local runs = 0
	local total = 0

	effect(function()
		runs += 1
		total = a() + b()
	end)

	asserts.eq(runs, 1)
	asserts.eq(total, 0)

	batch(function()
		setA(10)
		setB(20)
	end)

	asserts.eq(runs, 2)
	asserts.eq(total, 30)
end)

test.case("nested batches flush only after the outer batch", function(asserts)
	local value, setValue = signal(0)

	local runs = 0

	effect(function()
		value()
		runs += 1
	end)

	asserts.eq(runs, 1)

	batch(function()
		setValue(1)

		batch(function()
			setValue(2)
		end)

		asserts.eq(runs, 1)

		setValue(3)
	end)

	asserts.eq(runs, 2)
end)

test.case("batch restores scheduler state after errors", function(asserts)
	local value, setValue = signal(0)

	local runs = 0

	effect(function()
		value()
		runs += 1
	end)

	local success = pcall(function()
		batch(function()
			setValue(1)
			error("oops")
		end)
	end)

	asserts.eq(success, false)
	asserts.eq(runs, 2)

	setValue(2)

	asserts.eq(runs, 3)
end)