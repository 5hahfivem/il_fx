local groupBlips = {}
local groupDisplay = {}

local function kvpKey(group)
    return ('il_fx:blip:%s'):format(group)
end

---@param params { coords: vector3, sprite: integer, text: string, scale?: number, color?: integer, shortRange?: boolean, group?: string, resource?: string }
---@return integer blip
exports('createBlip', function(params)
    local blip = AddBlipForCoord(params.coords)
    SetBlipSprite(blip, params.sprite)
    SetBlipScale(blip, params.scale or 0.8)
    SetBlipColour(blip, params.color or 0)
    SetBlipAsShortRange(blip, params.shortRange ~= false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(params.text or '')
    EndTextCommandSetBlipName(blip)

    local group = params.group
    if group and group ~= '' then
        if not groupBlips[group] then groupBlips[group] = {} end

        local display = groupDisplay[group]
        if not display then
            display = GetResourceKvpInt(kvpKey(group))
            if display == 0 then
                display = 2
                SetResourceKvpInt(kvpKey(group), display)
            end
            groupDisplay[group] = display
        end

        SetBlipDisplay(blip, display)
        groupBlips[group][#groupBlips[group] + 1] = { blip = blip, resource = params.resource }
    end

    return blip
end)

---@return table<string, boolean>
exports('getBlipGroups', function()
    local groups = {}
    for group in pairs(groupBlips) do
        groups[group] = true
    end
    return groups
end)

---@param group string
---@return boolean visible
exports('toggleBlipGroup', function(group)
    local display = GetResourceKvpInt(kvpKey(group)) == 1 and 2 or 1
    SetResourceKvpInt(kvpKey(group), display)
    groupDisplay[group] = display

    if groupBlips[group] then
        for _, entry in ipairs(groupBlips[group]) do
            SetBlipDisplay(entry.blip, display)
        end
    end

    lib.notify({ description = display == 2 and 'Blips visible.' or 'Blips hidden.', type = 'inform' })
    return display == 2
end)

AddEventHandler('onResourceStop', function(resource)
    for _, blips in pairs(groupBlips) do
        for i = #blips, 1, -1 do
            if blips[i].resource == resource then
                RemoveBlip(blips[i].blip)
                table.remove(blips, i)
            end
        end
    end
end)
