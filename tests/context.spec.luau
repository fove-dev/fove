--!strict

local test = require("@std/test")

local Context = require("../src/core/internal/context")
local Types = require("../src/core/internal/types")

type Source = Types.Source
type Observer = Types.Observer

test.case("context restores the previous observer", function(asserts)
	local first: Observer = {
		dependencies = {},
		invalidate = function() end,
	}

	local second: Observer = {
		dependencies = {},
		invalidate = function() end,
	}

	local original = Context.setObserver(first)

	asserts.eq(Context.getObserver(), first)

	local previous = Context.setObserver(second)

	asserts.eq(previous, first)
	asserts.eq(Context.getObserver(), second)

	Context.setObserver(previous)

	asserts.eq(Context.getObserver(), first)

	Context.setObserver(original)
end)