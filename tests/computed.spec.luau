--!strict

local test = require(`@std/test`)
local Fove = require(`../src`)

local computed = Fove.computed
local signal = Fove.signal

test.case("computed is lazy", function(asserts)
	local runs = 0

	local value = computed(function()
		runs += 1
		return 10
	end)

	asserts.eq(runs, 0)

	asserts.eq(value(), 10)
	asserts.eq(runs, 1)
end)

test.case("computed caches its value", function(asserts)
	local runs = 0

	local value = computed(function()
		runs += 1
		return 10
	end)

	value()
	value()
	value()

	asserts.eq(runs, 1)
end)

test.case("computed recomputes lazily after dependency changes", function(asserts)
	local value, setValue = signal(10)
	local runs = 0

	local doubled = computed(function()
		runs += 1
		return value() * 2
	end)

	asserts.eq(doubled(), 20)
	asserts.eq(runs, 1)

	setValue(20)

	asserts.eq(runs, 1)

	asserts.eq(doubled(), 40)
	asserts.eq(runs, 2)
end)

test.case("computed values can depend on other computed values", function(asserts)
	local value, setValue = signal(2)

	local doubled = computed(function()
		return value() * 2
	end)

	local squared = computed(function()
		return doubled() ^ 2
	end)

	asserts.eq(squared(), 16)

	setValue(3)

	asserts.eq(squared(), 36)
end)

test.case("computed tracks dynamic dependencies", function(asserts)
	local enabled, setEnabled = signal(true)
	local a, setA = signal(1)
	local b, setB = signal(2)

	local runs = 0

	local selected = computed(function()
		runs += 1

		if enabled() then
			return a()
		end

		return b()
	end)

	asserts.eq(selected(), 1)
	asserts.eq(runs, 1)

	setEnabled(false)

	asserts.eq(selected(), 2)
	asserts.eq(runs, 2)

	setA(10)

	asserts.eq(selected(), 2)
	asserts.eq(runs, 2)

	setB(20)

	asserts.eq(selected(), 20)
	asserts.eq(runs, 3)
end)

test.case("computed supports optional values", function(asserts)
	local enabled, setEnabled = signal(false)

	local value = computed(function(): number?
		if enabled() then
			return 10
		end

		return nil
	end)

	asserts.eq(value(), nil)

	setEnabled(true)

	asserts.eq(value(), 10)

	setEnabled(false)

	asserts.eq(value(), nil)
end)

test.case("computed can retry after errors", function(asserts)
	local shouldFail, setShouldFail = signal(true)
	local runs = 0

	local value = computed(function()
		runs += 1

		if shouldFail() then
			error("oops")
		end

		return 10
	end)

	local success = pcall(value)

	asserts.eq(success, false)
	asserts.eq(runs, 1)

	setShouldFail(false)

	asserts.eq(value(), 10)
	asserts.eq(runs, 2)
end)

test.case("computed stays lazy across multiple invalidations", function(asserts)
	local a, setA = signal(1)
	local b, setB = signal(2)

	local runs = 0

	local total = computed(function()
		runs += 1
		return a() + b()
	end)

	asserts.eq(total(), 3)
	asserts.eq(runs, 1)

	setA(10)
	setB(20)

	asserts.eq(runs, 1)

	asserts.eq(total(), 30)
	asserts.eq(runs, 2)
end)