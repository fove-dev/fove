--!strict

local test = require("@std/test")

local Context = require("../src/core/internal/context")
local Graph = require("../src/core/internal/graph")
local Types = require("../src/core/internal/types")

type Source = Types.Source
type Observer = Types.Observer

test.case("graph tracks dependencies", function(asserts)
	local source: Source = {
		subscribers = {},
	}

	local observer: Observer = {
		dependencies = {},
		invalidate = function() end,
	}

	local previous = Context.setObserver(observer)

	Graph.track(source)

	Context.setObserver(previous)

	asserts.eq(source.subscribers[observer], true)
	asserts.eq(observer.dependencies[source], true)
end)

test.case("graph ignores reads without an active observer", function(asserts)
	local source: Source = {
		subscribers = {},
	}

	Context.setObserver(nil)

	Graph.track(source)

	local hasSubscriber = next(source.subscribers) ~= nil

	asserts.eq(hasSubscriber, false)
end)

test.case("graph does not duplicate dependencies", function(asserts)
	local source: Source = {
		subscribers = {},
	}

	local observer: Observer = {
		dependencies = {},
		invalidate = function() end,
	}

	local previous = Context.setObserver(observer)

	Graph.track(source)
	Graph.track(source)

	Context.setObserver(previous)

	local subscriberCount = 0
	for _ in source.subscribers do
		subscriberCount += 1
	end

	local dependencyCount = 0
	for _ in observer.dependencies do
		dependencyCount += 1
	end

	asserts.eq(1, subscriberCount)
	asserts.eq(1, dependencyCount)
end)