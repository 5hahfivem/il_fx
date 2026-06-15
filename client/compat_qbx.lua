if GetConvar('il_fx:qbxCompat', 'false') ~= 'true' then return end

PlayerData = {}

local function toQb(data)
    if not data or not data.occupation then return {} end

    local occupation = data.occupation
    local affiliation = data.affiliation

    return {
        source = data.source,
        citizenid = tostring(data.stateId),
        name = data.displayName,
        charinfo = {
            firstname = data.identity and data.identity.firstName,
            lastname = data.identity and data.identity.lastName,
            nationality = data.identity and data.identity.nationality,
        },
        money = {
            cash = data.accounts.cash,
            bank = data.accounts.bank,
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
        metadata = data.metadata,
    }
end

AddEventHandler('core:client:onCharacterLoaded', function(data)
    PlayerData = toQb(data)
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
    PlayerData.gang = gang
end)

local QBCore = {
    Functions = {
        GetPlayerData = function(cb)
            if cb then return cb(PlayerData) end
            return PlayerData
        end,
        Notify = function(message, kind) lib.notify({ description = message, type = kind }) end,
    },
}

exports('GetCoreObject', function() return QBCore end)
exports('GetPlayerData', function() return PlayerData end)
