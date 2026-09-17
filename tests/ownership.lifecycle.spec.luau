--!strict

local test = require(`@std/test`)

local Fove = require(`../src`)
local Ownership = require(`../src/core/internal/ownership`)

local signal = Fove.signal
local computed = Fove.computed

test.case("ownership disposes callbacks in reverse order", function(asserts)
	local owner = Ownership.create()
	local order = {}

	Ownership.run(owner, function()
		Ownership.register(function()
			table.insert(order, "first")
		end)

		Ownership.register(function()
			table.insert(order, "second")
		end)

		Ownership.register(function()
			table.insert(order, "third")
		end)
	end)

	Ownership.dispose(owner)

	asserts.eq(order[1], "third")
	asserts.eq(order[2], "second")
	asserts.eq(order[3], "first")
end)

test.case("ownership dispose remains idempotent", function(asserts)
	local owner = Ownership.create()
	local runs = 0

	Ownership.run(owner, function()
		Ownership.register(function()
			runs += 1
		end)
	end)

	Ownership.dispose(owner)
	Ownership.dispose(owner)

	asserts.eq(runs, 1)
end)

test.case("owned computed values cannot be reused after disposal", function(asserts)
	local owner = Ownership.create()
	local source, setSource = signal(1)

	local runs = 0
	local derived: (() -> number)? = nil

	Ownership.run(owner, function()
		derived = computed(function()
			runs += 1
			return source() * 2
		end)

		asserts.eq((derived :: () -> number)(), 2)
	end)

	asserts.eq(runs, 1)

	Ownership.dispose(owner)

	setSource(2)

	local success = pcall(function()
		(derived :: () -> number)()
	end)

	asserts.eq(success, false)
	asserts.eq(runs, 1)
end)