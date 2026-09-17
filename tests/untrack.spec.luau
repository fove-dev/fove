--!strict

local test = require(`@std/test`)
local Fove = require(`../src`)

local onCleanup = Fove.onCleanup
local untrack = Fove.untrack
local effect = Fove.effect
local signal = Fove.signal


test.case("untrack prevents dependency tracking", function(asserts)
	local tracked, setTracked = signal(0)
	local untracked, setUntracked = signal(0)

	local runs = 0

	effect(function()
		runs += 1

		tracked()

		untrack(function()
			return untracked()
		end)
	end)

	asserts.eq(runs, 1)

	setUntracked(1)

	asserts.eq(runs, 1)

	setTracked(1)

	asserts.eq(runs, 2)
end)

test.case("untrack restores tracking after errors", function(asserts)
	local value, setValue = signal(0)

	local runs = 0

	effect(function()
		runs += 1

		pcall(function()
			untrack(function()
				error("oops")
			end)
		end)

		value()
	end)

	asserts.eq(runs, 1)

	setValue(1)

	asserts.eq(runs, 2)
end)

test.case("untrack preserves ownership context", function(asserts)
	local cleaned = false

	local dispose = effect(function()
		untrack(function()
			onCleanup(function()
				cleaned = true
			end)

			return nil
		end)
	end)

	asserts.eq(cleaned, false)

	dispose()

	asserts.eq(cleaned, true)
end)