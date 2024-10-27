local Config = require 'config'

local function OpenLeaderboard()
    local leaderboard = lib.callback.await('p_halloween:fetchLeaderboard', false)
    if leaderboard then
        SendNUIMessage({
            action = 'OpenLeaderboard',
            leaderboard = leaderboard
        })
        SetNuiFocus(true, true)
    end
end

RegisterNUICallback('CloseUI', function()
    SetNuiFocus(false, false)
end)

Citizen.CreateThread(function()
    local pedData = Config.NPC
    lib.requestModel(pedData.model)
    local ped = CreatePed(4, GetHashKey(pedData.model), pedData.coords, false, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    exports['ox_target']:addLocalEntity(ped, {
        {
            name = 'Halloween_Leaderboard',
            label = 'Leaderboard',
            icon = 'fa-solid fa-list',
            distance = 2,
            onSelect = OpenLeaderboard
        },
        {
            name = 'Halloween_Pumpkin',
            label = 'Give pumpkins',
            icon = 'fa-solid fa-hand',
            distance = 2,
            onSelect = function()
                TriggerServerEvent('p_halloween:GivePumpkins')
            end
        }
    })
end)