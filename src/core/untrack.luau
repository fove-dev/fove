--!strict

local Context = require(`./internal/context`)

type Untrack = <R...>(callback: () -> R...) -> R...

local function untrack(callback: () -> ...any): ...any

    local previous = Context.setObserver(nil)
    local results = table.pack(pcall(callback))

    Context.setObserver(previous)

    if not results[1] then error(results[2], 0) end

    return table.unpack(results, 2, results.n)
end

return untrack:: Untrack