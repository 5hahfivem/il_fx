if GetConvar('il_fx:qbxCompat', 'false') ~= 'true' then return end

---@param character Character
---@return table?
local function toQb(character)
    if not character then return nil end

    local occupation = character.occupation
    local affiliation = character.affiliation

    return {
        PlayerData = {
            source = character.source,
            citizenid = tostring(character.stateId),
            license = character.license,
            name = character.displayName,
            charinfo = {
                firstname = character.identity.firstName,
                lastname = character.identity.lastName,
                nationality = character.identity.nationality,
                birthdate = character.identity.dateOfBirth,
            },
            money = {
                cash = character:getBalance('cash'),
                bank = character:getBalance('bank'),
            },
            job = {
                name = occupation.id,
                label = occupation.label,
                type = occupation.category,
                onduty = true,
                isboss = occupation.isLeader,
                payment = occupation.salary,
                grade = { level = occupation.rank, name = occupation.title },
            },
            gang = {
                name = affiliation.id,
                label = affiliation.label,
                isboss = affiliation.isLeader,
                grade = { level = affiliation.rank, name = affiliation.title },
            },
            metadata = character.metadata,
        },
        Functions = {
            SetJob = function(name, grade) return character:setOccupation(name, grade) end,
            SetGang = function(name, grade) return character:setAffiliation(name, grade) end,
            GetMoney = function(account) return character:getBalance(account) end,
            AddMoney = function(account, amount)
                local ok = character:addBalance(account, amount)
                if ok then character:save() end
                return ok
            end,
            RemoveMoney = function(account, amount)
                local ok = character:removeBalance(account, amount)
                if ok then character:save() end
                return ok
            end,
            SetMetaData = function(key, value)
                character:setMeta(key, value)
                character:save()
                return true
            end,
            GetMetaData = function(key) return character:getMeta(key) end,
            Save = function() character:save() end,
        },
    }
end

local function convertJobs()
    local out = {}
    for id, job in pairs(Config.Jobs) do
        local grades = {}
        for level, rank in pairs(job.ranks) do
            grades[tostring(level)] = { name = rank.title, payment = rank.salary or 0, isboss = rank.isLeader or false }
        end
        out[id] = { label = job.label, type = job.category, grades = grades }
    end
    return out
end

local function convertGangs()
    local out = {}
    for id, gang in pairs(Config.Gangs) do
        local grades = {}
        for level, rank in pairs(gang.ranks) do
            grades[tostring(level)] = { name = rank.title, isboss = rank.isLeader or false }
        end
        out[id] = { label = gang.label, grades = grades }
    end
    return out
end

local QBCore = {
    Functions = {
        GetPlayer = function(source) return toQb(Core.Characters[source]) end,
        GetPlayerByCitizenId = function(citizenid) return toQb(Core.GetCharacterByStateId(tonumber(citizenid))) end,
        GetPlayers = function()
            local ids = {}
            for source in pairs(Core.Characters) do ids[#ids + 1] = source end
            return ids
        end,
        Notify = function(source, message, kind) Core.Notify(source, message, kind) end,
    },
    Shared = {
        Jobs = convertJobs(),
        Gangs = convertGangs(),
    },
}

exports('GetCoreObject', function() return QBCore end)
exports('GetPlayer', function(source) return toQb(Core.Characters[source]) end)
exports('GetPlayerByCitizenId', function(citizenid) return toQb(Core.GetCharacterByStateId(tonumber(citizenid))) end)
exports('GetQBPlayers', function() return QBCore.Functions.GetPlayers() end)

AddEventHandler('core:server:characterLoaded', function(source)
    local player = toQb(Core.Characters[source])
    if not player then return end
    TriggerEvent('QBCore:Server:OnPlayerLoaded', player)
    TriggerClientEvent('QBCore:Client:OnPlayerLoaded', source)
end)

AddEventHandler('core:server:occupationChanged', function(source)
    local player = toQb(Core.Characters[source])
    if not player then return end
    TriggerEvent('QBCore:Server:OnJobUpdate', source, player.PlayerData.job)
    TriggerClientEvent('QBCore:Client:OnJobUpdate', source, player.PlayerData.job)
end)

AddEventHandler('core:server:affiliationChanged', function(source)
    local player = toQb(Core.Characters[source])
    if not player then return end
    TriggerClientEvent('QBCore:Client:OnGangUpdate', source, player.PlayerData.gang)
end)

AddEventHandler('playerDropped', function()
    TriggerEvent('QBCore:Server:OnPlayerUnload', source)
end)
