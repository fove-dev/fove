--!strict

local test = require(`@std/test`)
local Fove = require(`../src`)

local computed = Fove.computed
local signal = Fove.signal
local effect = Fove.effect

test.case("diamond graph updates effects only once", function(asserts)
	local a, setA = signal(1)

	local b = computed(function()
		return a() * 2
	end)

	local c = computed(function()
		return a() * 3
	end)

	local d = computed(function()
		return b() + c()
	end)

	local runs = 0
	local value = 0

	effect(function()
		runs += 1
		value = d()
	end)

	asserts.eq(runs, 1)
	asserts.eq(value, 5)

	setA(2)

	asserts.eq(runs, 2)
	asserts.eq(value, 10)
end)

test.case("diamond graph never exposes intermediate values", function(asserts)
	local a, setA = signal(1)

	local b = computed(function()
		return a() * 10
	end)

	local c = computed(function()
		return a() * 100
	end)

	local d = computed(function()
		return b() + c()
	end)

	local values = {}

	effect(function()
		table.insert(values, d())
	end)

	setA(2)

	asserts.eq(#values, 2)
	asserts.eq(values[1], 110)
	asserts.eq(values[2], 220)
end)