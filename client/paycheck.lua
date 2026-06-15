local cfg = Config.Paycheck.Ped
local controlJustReleased = IsControlJustReleased

CreateThread(function()
    if cfg.blip and cfg.blip.enabled then
        local blip = AddBlipForCoord(cfg.coords.x, cfg.coords.y, cfg.coords.z)
        SetBlipSprite(blip, cfg.blip.sprite)
        SetBlipColour(blip, cfg.blip.color)
        SetBlipScale(blip, cfg.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(cfg.blip.label)
        EndTextCommandSetBlipName(blip)
    end

    lib.requestModel(cfg.model)
    local ped = CreatePed(4, cfg.model, cfg.coords.x, cfg.coords.y, cfg.coords.z - 1.0, cfg.coords.w, false, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    if cfg.scenario then
        TaskStartScenarioInPlace(ped, cfg.scenario, 0, true)
    end
    SetModelAsNoLongerNeeded(cfg.model)
end)

local point = lib.points.new({
    coords = cfg.coords.xyz,
    distance = 2.0,
})

function point:onEnter()
    lib.showTextUI('[E] Collect Paycheck')
end

function point:onExit()
    lib.hideTextUI()
end

function point:nearby()
    if controlJustReleased(0, 38) then
        local collected = lib.callback.await('core:collectPaycheck', false)
        if collected then
            lib.hideTextUI()
        end
    end
end
