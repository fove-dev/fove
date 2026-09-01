local function signal<T>(initialValue: T): (()->T, (T)->()) 
    
    local value = initialValue

    local function get(): T
        
        return value
    end

    local function set(newValue: T): ()
        
        if value == newValue then return end

        value = newValue
    end

    return get, set
end

return signal