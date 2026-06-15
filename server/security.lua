local function guardScalar(key)
    AddStateBagChangeHandler(key, nil, function(bagName, _, value)
        local source = GetPlayerFromStateBagName(bagName)
        if source == 0 then return end

        local character = Core.Characters[source]
        if not character then return end

        if value ~= character[key] then
            Player(source).state:set(key, character[key], true)
        end
    end)
end

local function guardRanked(key)
    AddStateBagChangeHandler(key, nil, function(bagName, _, value)
        local source = GetPlayerFromStateBagName(bagName)
        if source == 0 then return end

        local character = Core.Characters[source]
        if not character then return end

        local current = character[key]
        if type(value) ~= 'table' or value.id ~= current.id or value.rank ~= current.rank then
            Player(source).state:set(key, current, true)
        end
    end)
end

guardScalar('stateId')
guardScalar('displayName')
guardRanked('occupation')
guardRanked('affiliation')
