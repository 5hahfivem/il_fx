local decode = json.decode

lib.callback.register('il_fx:fetchCharacters', function(source)
    local license = GetPlayerIdentifierByType(source, 'license')
    if not license then return {} end

    local rows = MySQL.query.await('SELECT state_id, display_name, identity, accounts FROM characters WHERE license = ?', { license })
    local list = {}

    for i = 1, #rows do
        local row = rows[i]
        local identity = row.identity and decode(row.identity) or {}
        local accounts = row.accounts and decode(row.accounts) or {}
        list[i] = {
            stateId = row.state_id,
            displayName = row.display_name,
            firstName = identity.firstName,
            lastName = identity.lastName,
            gender = identity.gender,
            dateOfBirth = identity.dateOfBirth,
            nationality = identity.nationality,
            cash = accounts.cash,
            bank = accounts.bank,
        }
    end

    return list
end)

lib.callback.register('il_fx:createCharacter', function(source, data)
    if Core.Characters[source] then return false end

    local license = GetPlayerIdentifierByType(source, 'license')
    if not license then return false end

    if MySQL.scalar.await('SELECT 1 FROM characters WHERE license = ?', { license }) then
        return false, 'limit'
    end

    local record = Core.InsertCharacter(source, license, {
        firstName = data.firstname or data.firstName,
        lastName = data.lastname or data.lastName,
        gender = data.gender == 'f' and 'female' or 'male',
        dateOfBirth = data.dob or data.dateOfBirth,
        nationality = data.nationality,
    })

    if not record then return false, 'invalid' end
    return record.stateId
end)

lib.callback.register('il_fx:selectCharacter', function(source, stateId)
    if Core.Characters[source] then
        return Core.Characters[source]:toExport()
    end

    stateId = tonumber(stateId)
    local license = GetPlayerIdentifierByType(source, 'license')
    local row = MySQL.single.await('SELECT * FROM characters WHERE state_id = ? AND license = ?', { stateId, license })
    if not row then return false end

    local character = Core.LoadCharacter(source, row)
    TriggerClientEvent('core:client:characterLoaded', source, character:toExport())
    TriggerEvent('core:server:characterLoaded', source)
    print(('[il_fx] %s selected (StateID %d)'):format(GetPlayerName(source), character.stateId))

    return character:toExport()
end)

lib.callback.register('il_fx:deleteCharacter', function(source, stateId)
    stateId = tonumber(stateId)
    local license = GetPlayerIdentifierByType(source, 'license')

    MySQL.update.await('DELETE FROM characters WHERE state_id = ? AND license = ?', { stateId, license })

    local character = Core.Characters[source]
    if character and character.stateId == stateId then
        Core.Characters[source] = nil
    end

    return true
end)
