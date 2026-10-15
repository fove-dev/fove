--!strict

local test = require(`@std/test`)
local Fove = require(`../src`)
local Types = require(`../src/core/internal/types`)
local Context = require(`../src/core/internal/context`)

type Observer = Types.Observer

local onCleanup = Fove.onCleanup
local signal = Fove.signal
local effect = Fove.effect

test.case("disposed effects stop reacting", function(asserts)
	local value, setValue = signal(0)

	local runs = 0

	local dispose = effect(function()
		value()
		runs += 1
	end)

	asserts.eq(runs, 1)

	setValue(1)

	asserts.eq(runs, 2)

	dispose()

	setValue(2)

	asserts.eq(runs, 2)
end)

test.case("effect restores observer context after errors", function(asserts)
	local success = pcall(function()
		effect(function()
			error("oops")
		end)
	end)

	asserts.eq(success, false)
	asserts.eq(Context.getObserver(), nil)
end)

test.case("failed effects do not remain subscribed", function(asserts)
	local value, setValue = signal(0)
	local runs = 0

	pcall(function()
		effect(function()
			value()
			runs += 1
			error("oops")
		end)
	end)

	asserts.eq(runs, 1)

	local success = pcall(function()
		setValue(1)
	end)

	asserts.eq(success, true)
	asserts.eq(runs, 1)

	asserts.eq(runs, 1)
end)

test.case("failed effects dispose their run owner", function(asserts)
	local trigger, setTrigger = signal(false)

	local runs = 0
	local cleanups = 0

	effect(function()
		runs += 1

		if trigger() then
			onCleanup(function()
				cleanups += 1
			end)

			error("oops")
		end
	end)

	asserts.eq(runs, 1)
	asserts.eq(cleanups, 0)

	local success = pcall(function()
		setTrigger(true)
	end)

	asserts.eq(success, false)
	asserts.eq(runs, 2)
	asserts.eq(cleanups, 1)

	setTrigger(false)

	asserts.eq(runs, 2)
	asserts.eq(cleanups, 1)
end)

test.case("effects finish execution before rerunning", function(asserts)
    local value, setValue = signal(0)
    local order = {}

    effect(function()
        local current = value()

        table.insert(order, `start-{current}`)

        onCleanup(function()
            table.insert(order, `cleanup-{current}`)
        end)

        if current == 0 then
            setValue(1)
        end

        table.insert(order, `end-{current}`)
    end)

    asserts.eq(#order, 5)
    asserts.eq(order[1], "start-0")
    asserts.eq(order[2], "end-0")
    asserts.eq(order[3], "cleanup-0")
    asserts.eq(order[4], "start-1")
    asserts.eq(order[5], "end-1")
end)

test.case("cleanup errors prevent subsequent effect executions", function(asserts)
    local value, setValue = signal(0)
    local runs = 0

    effect(function()
        value()
        runs += 1

        onCleanup(function()
            error("cleanup failed")
        end)
    end)

    asserts.eq(runs, 1)

    local success = pcall(function()
        setValue(1)
    end)

    asserts.eq(success, false)
    asserts.eq(runs, 1)

    local recovered = pcall(function()
        setValue(2)
    end)

    asserts.eq(recovered, true)
    asserts.eq(runs, 1)
end)

test.case("effect preserves callback errors when cleanup fails", function(asserts)
    local cleanups = 0

    local success, err = pcall(function()
        effect(function()
            onCleanup(function()
                cleanups += 1
                error("cleanup failed")
            end)

            error("effect failed")
        end)
    end)

    asserts.eq(success, false)
    asserts.eq(cleanups, 1)

    asserts.eq(
        string.find(tostring(err), "effect failed", 1, true) ~= nil,
        true
    )
end)

test.case("disposing during cleanup prevents effect rerun", function(asserts)
    local value, setValue = signal(0)
    local runs = 0

    local dispose: (() -> ())? = nil

    dispose = effect(function()
        value()
        runs += 1

        onCleanup(function()
            (dispose :: () -> ())()
        end)
    end)

    asserts.eq(runs, 1)

    setValue(1)

    asserts.eq(runs, 1)

    setValue(2)

    asserts.eq(runs, 1)
end)

test.case("disposed effects do not retain dependencies", function(asserts)
    local trigger, setTrigger = signal(0)
    local other, setOther = signal(0)

    local runs = 0
    local dispose: (() -> ())? = nil
    local trackedObserver: Observer? = nil

    dispose = effect(function()
        runs += 1

        if trigger() == 1 then
            trackedObserver = Context.getObserver()

            assert(dispose, "dispose is nil")()

            other()
        end
    end)

    setTrigger(1)

    asserts.eq(runs, 2)
    asserts.eq(next((trackedObserver:: Observer).dependencies), nil)

    setOther(1)
    setTrigger(2)

    asserts.eq(runs, 2)
end)