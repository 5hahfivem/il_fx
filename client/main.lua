---@type table
LocalCharacter = {}
local loaded = false
local creationCam

local function clearCreationCam()
    if creationCam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(creationCam, false)
        creationCam = nil
    end
end

local function releasePed()
    local ped = PlayerPedId()
    SetEntityVisible(ped, true, false)
    SetEntityCollision(ped, true, true)
    FreezeEntityPosition(ped, false)
    SetPlayerInvincible(PlayerId(), false)
end

local function enterLimbo()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    local ped = PlayerPedId()
    local cam = Config.Camera
    SetEntityCoords(ped, cam.coords.x, cam.coords.y, cam.coords.z - 20.0, false, false, false, false)
    SetEntityVisible(ped, false, false)
    SetEntityCollision(ped, false, false)
    FreezeEntityPosition(ped, true)
    SetPlayerInvincible(PlayerId(), true)
    if not IsPedFatallyInjured(ped) then
        ClearPedTasksImmediately(ped)
    end

    clearCreationCam()
    creationCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(creationCam, cam.coords.x, cam.coords.y, cam.coords.z)
    SetCamRot(creationCam, cam.rotation.x, cam.rotation.y, cam.rotation.z, 2)
    SetCamActive(creationCam, true)
    RenderScriptCams(true, false, 0, true, true)
    DoScreenFadeIn(500)
end

---@param data table
local function spawnCharacter(data)
    local model = (data.identity and data.identity.gender == 'female') and `mp_f_freemode_01` or `mp_m_freemode_01`
    local pos = Config.SpawnPosition

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    exports.spawnmanager:spawnPlayer({
        x = pos.x,
        y = pos.y,
        z = pos.z,
        heading = pos.w,
        model = model,
        skipFade = true,
    }, function()
        SetPedDefaultComponentVariation(PlayerPedId())
        clearCreationCam()
        releasePed()
        ShutdownLoadingScreenNui()
        DoScreenFadeIn(500)
    end)
end

local function requestLoad()
    while not loaded do
        TriggerServerEvent('core:server:characterReady')
        Wait(2000)
    end
end

CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(250)
    end
    while GetResourceState('spawnmanager') ~= 'started' do
        Wait(0)
    end
    exports.spawnmanager:setAutoSpawn(false)
    enterLimbo()
    requestLoad()
end)

RegisterNetEvent('core:client:characterLoaded', function(data)
    LocalCharacter = data
    loaded = true
    spawnCharacter(data)
    TriggerEvent('core:client:onCharacterLoaded', data)
end)

RegisterNetEvent('core:client:logout', function()
    loaded = false
    LocalCharacter = {}
    enterLimbo()
    requestLoad()
end)

lib.callback.register('core:requestIdentity', function()
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

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    clearCreationCam()
    releasePed()
    DoScreenFadeIn(0)
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
