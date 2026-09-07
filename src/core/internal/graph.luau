--!strict

local Types = require(`./types`)
local Context = require(`./context`)

type Observer = Types.Observer
type Source = Types.Source

local Graph = {}

function Graph.track(source: Source): ()
    
    local observer = Context.getObserver()
    if observer == nil then return end

    source.subscribers[observer] = true
    observer.dependencies[source] = true
end

function Graph.notify(source: Source): ()

	local subscribers = {}

	for observer in source.subscribers do

		table.insert(subscribers, observer)
	end

	for _,observer in subscribers do

		observer.invalidate()
	end
end

function Graph.detach(observer: Observer): ()

	for source in observer.dependencies do
        
		source.subscribers[observer] = nil
	end

	table.clear(observer.dependencies)
end

return Graph