local Core = {}

local ESX = exports['es_extended']:getSharedObject()

Core.GetPlayerIdentifier = function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    return xPlayer and xPlayer.identifier or nil
end

return Core