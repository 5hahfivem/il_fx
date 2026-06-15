---@param character Character
---@return integer amount, string? label
local function computePaycheck(character)
    local occupation = character.occupation
    local job = occupation and Config.Jobs[occupation.id]
    local rank = job and job.ranks[occupation.rank]
    local salary = rank and rank.salary or 0

    if salary <= 0 then
        return Config.Paycheck.UBI, nil
    end

    return salary, ('%s - %s'):format(job.label, rank.title)
end

---@param amount integer
---@param label? string
---@return string
local function paycheckMessage(amount, label)
    if label then
        return ('Your Paycheck of $%s is ready (%s)'):format(amount, label)
    end
    return ('Your UBI paycheck of $%s is ready'):format(amount)
end

lib.cron.new(Config.Paycheck.Schedule, function()
    for source, character in pairs(Core.Characters) do
        local amount, label = computePaycheck(character)
        if amount and amount > 0 then
            local pending = (character:getMeta('pendingPaycheck') or 0) + amount
            character:setMeta('pendingPaycheck', pending)
            character:save()
            Core.Notify(source, paycheckMessage(amount, label), 'inform')
        end
    end
end)

local collectCooldown = {}

lib.callback.register('core:collectPaycheck', function(source)
    local now = GetGameTimer()
    if collectCooldown[source] and now - collectCooldown[source] < 1000 then return false end
    collectCooldown[source] = now

    local character = Core.Characters[source]
    if not character then return false end

    local distance = #(GetEntityCoords(GetPlayerPed(source)) - Config.Paycheck.Ped.coords.xyz)
    if distance > Config.Paycheck.CollectDistance then
        Core.Notify(source, 'You are too far from the paycheck collection point.', 'error')
        return false
    end

    local pending = character:getMeta('pendingPaycheck') or 0
    if pending <= 0 then
        Core.Notify(source, 'You have no paycheck waiting to be collected.', 'error')
        return false
    end

    character:addBalance(Config.Paycheck.Account, pending)
    character:setMeta('pendingPaycheck', 0)
    character:save()

    Core.Notify(source, ('You collected $%s.'):format(pending), 'success')
    return true, pending
end)

AddEventHandler('playerDropped', function()
    collectCooldown[source] = nil
end)
