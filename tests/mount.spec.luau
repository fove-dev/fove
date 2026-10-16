--!strict

local test = require(`@std/test`)
local Fove = require(`../src`)

local signal = Fove.signal
local effect = Fove.effect
local mount = Fove.mount

test.case("destroying a root disposes owned effects", function(asserts)
	local value, setValue = signal(0)
	local runs = 0

	local root = mount(nil :: any, function()
		effect(function()
			value()
			runs += 1
		end)
	end)

	asserts.eq(runs, 1)

	setValue(1)
	asserts.eq(runs, 2)

	root:destroy()

	setValue(2)
	asserts.eq(runs, 2)
end)

test.case("destroying a root remains idempotent", function(asserts)
	local cleanups = 0

	local root = mount(nil :: any, function()
		Fove.onCleanup(function()
			cleanups += 1
		end)
	end)

	root:destroy()
	root:destroy()
	root:destroy()

	asserts.eq(cleanups, 1)
end)

test.case("failed mounts dispose partial ownership", function(asserts)
	local value, setValue = signal(0)
	local runs = 0

	local success = pcall(function()
		mount(nil :: any, function()
			effect(function()
				value()
				runs += 1
			end)

			error("oops")
		end)
	end)

	asserts.eq(success, false)
	asserts.eq(runs, 1)

	setValue(1)

	asserts.eq(runs, 1)
end)

test.case("failed mounts preserve original errors when cleanup fails", function(asserts)
    local cleanups = 0

    local success, err = pcall(function()
        mount(nil :: any, function()
            Fove.onCleanup(function()
                cleanups += 1
                error("cleanup failed")
            end)

            error("mount failed")
        end)
    end)

    asserts.eq(success, false)
    asserts.eq(cleanups, 1)

    asserts.eq(
        string.find(tostring(err), "mount failed", 1, true) ~= nil,
        true
    )
end)

test.case("multiple roots remain independent", function(asserts)
    local value, setValue = signal(0)

    local firstRuns = 0
    local secondRuns = 0

    local first = mount(nil :: any, function()
        effect(function()
            value()
            firstRuns += 1
        end)
    end)

    local second = mount(nil :: any, function()
        effect(function()
            value()
            secondRuns += 1
        end)
    end)

    setValue(1)

    asserts.eq(firstRuns, 2)
    asserts.eq(secondRuns, 2)

    first:destroy()
    setValue(2)

    asserts.eq(firstRuns, 2)
    asserts.eq(secondRuns, 3)

    second:destroy()
    setValue(3)

    asserts.eq(firstRuns, 2)
    asserts.eq(secondRuns, 3)
end)