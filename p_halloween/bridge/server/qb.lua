local Core = {}

local QBCore = exports['qb-core']:GetCoreObject()

Core.GetPlayerIdentifier = function(playerId)
    local xPlayer = QBCore.Functions.GetPlayer(playerId)
    return xPlayer and xPlayer.PlayerData.license or nil
end

return Core