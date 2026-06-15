---@type table
LocalCharacter = {}
local loaded = false

CreateThread(function()
    while GetResourceState('spawnmanager') ~= 'started' do
        Wait(0)
    end
    exports.spawnmanager:setAutoSpawn(false)
end)

CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(250)
    end
    while not loaded do
        TriggerServerEvent('core:server:characterReady')
        Wait(2000)
    end
end)

---@param data table
local function spawnCharacter(data)
    local model = (data.identity and data.identity.gender == 'female') and `mp_f_freemode_01` or `mp_m_freemode_01`
    local pos = Config.SpawnPosition
    exports.spawnmanager:spawnPlayer({
        x = pos.x,
        y = pos.y,
        z = pos.z,
        heading = pos.w,
        model = model,
    }, function()
        ShutdownLoadingScreenNui()
    end)
end

RegisterNetEvent('core:client:characterLoaded', function(data)
    LocalCharacter = data
    loaded = true
    spawnCharacter(data)
    TriggerEvent('core:client:onCharacterLoaded', data)
end)

lib.callback.register('core:requestIdentity', function()
    ShutdownLoadingScreenNui()
    Wait(1000)

    local input = lib.inputDialog('Create your character', {
        { type = 'input', label = 'First Name', name = 'firstName', required = true, max = 24 },
        { type = 'input', label = 'Last Name', name = 'lastName', required = true, max = 24 },
        { type = 'select', label = 'Gender', name = 'gender', required = true, options = {
            { value = 'male', label = 'Male' },
            { value = 'female', label = 'Female' },
        } },
        { type = 'date', label = 'Date of Birth', name = 'dateOfBirth', required = true },
        { type = 'select', label = 'Nationality', name = 'nationality', required = true, options = Config.Nationalities },
    })

    if not input then return nil end

    return {
        firstName = input[1],
        lastName = input[2],
        gender = input[3],
        dateOfBirth = input[4],
        nationality = input[5],
    }
end)

---@return boolean
exports('IsLoaded', function()
    return loaded
end)

---@return table
exports('GetCharacter', function()
    return LocalCharacter
end)

---@return integer
exports('GetStateId', function()
    return LocalPlayer.state.stateId
end)
