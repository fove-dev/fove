--!strict

local Ownership = require(`../core/internal/ownership`)
local Context = require(`./internal/context`)

type Props = { [string]: unknown }

local function new(className: string): (Props) -> Instance

    return function(props: Props): Instance

        local instance = Instance.new(className)
        local writable = instance:: any

        local success, err = pcall(function()

            for property, value in props do
                
                if property == "Parent" then continue end

                writable[property] = value
            end

            writable.Parent = props.Parent or Context.getParent()
        end)

        if not success then
            pcall(instance.Destroy, instance)
            error(err, 0)
        end

        Ownership.register(function()
            instance:Destroy()
        end)

        return instance
    end
end

return new