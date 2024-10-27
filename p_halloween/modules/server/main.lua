local discordGuildId = ''
local discordBotToken = ''
local Config = require 'config'
local Core = require ('bridge.server.'..string.lower(Config.Framework))

if discordGuildId == '' or discordBotToken == '' then
    Citizen.CreateThread(function()
        while true do
            Wait(5000)
            print('^1---------------------------------------------------------')
            print('---------------------------------------------------------')
            print('---------------------------------------------------------')
            print('------- SETUP DISCORD IN MODULES/SERVER/MAIN.LUA --------')
            print('---------------------------------------------------------')
            print('---------------------------------------------------------')
            print('---------------------------------------------------------^7')
        end
    end)
    return
end

local fetchPlayerIdentifier = function(player, identifier)
    local identifiers = GetPlayerIdentifiers(player)
    local plyIdentifier = nil
    for i = 1, #identifiers, 1 do
        if string.find(identifiers[i], identifier) then
            plyIdentifier = string.gsub(identifiers[i], identifier, "")
            break
        end
    end
    return plyIdentifier
end

local fetchUserDiscord = function(player)
    local promise = promise.new()
    local discordId = fetchPlayerIdentifier(player, "discord:")
    if not discordId then
        promise:resolve({
            name = GetPlayerName(player),
            image = 'https://cdn-icons-png.flaticon.com/512/6596/6596121.png'
        })
    else
        PerformHttpRequest("https://discord.com/api/v9/guilds/"..discordGuildId.."/members/"..discordId, function(err, text, headers)
            local discordData = json.decode(text)
            if discordData then
                local discordName, discordAvatar = nil, nil
                if discordData.nick then
                    discordName = discordData.nick
                else
                    discordName = discordData.user.username
                end
    
                if discordData.user.avatar then
                    discordAvatar = "https://cdn.discordapp.com/avatars/"..discordId.."/"..discordData.user.avatar..".webp?size=128"
                else
                    discordAvatar = "https://cdn-icons-png.flaticon.com/512/6596/6596121.png"
                end
    
                promise:resolve({
                    name = discordName,
                    image = discordAvatar,
                })
            else
                promise:resolve({
                    name = GetPlayerName(player),
                    image = 'https://cdn-icons-png.flaticon.com/512/6596/6596121.png',
                })
            end
        end, 'GET', nil, {['Content-Type'] = 'application/json', ["Authorization"] = "Bot "..discordBotToken})
    end

    local await = Citizen.Await(promise)
    return await
end

local getPlayerPumpkins = function(identifier)
    local result = MySQL.single.await('SELECT pumpkins FROM halloween_leaderboard WHERE identifier = ?', {identifier})
    if result and result.pumpkins then
        return tonumber(result.pumpkins)
    end

    return 0
end

RegisterNetEvent('p_halloween:GivePumpkins', function()
    local _source = source
    local plyPed = GetPlayerPed(_source)
    local plyCoords = GetEntityCoords(plyPed)
    local pedCoords = Config.NPC.coords
    if #(vector3(plyCoords.x, plyCoords.y, plyCoords.z) - vector3(pedCoords.x, pedCoords.y, pedCoords.z)) > 3.0 then
        return
    end

    local pumpkinsCount = exports['ox_inventory']:Search(_source, 'count', Config.PumpkinItem)
    if pumpkinsCount and pumpkinsCount < 1 then
        TriggerClientEvent('ox_lib:notify', _source, {
            id = 'halloween',
            title = 'Halloween',
            description = 'You dont have any pumpkins',
            duration = 5000,
            type = 'error',
        })
        return
    end

    local plyIdentifier = Core.GetPlayerIdentifier(_source)
    if not plyIdentifier then
        return
    end

    local removedPumpkins = exports['ox_inventory']:RemoveItem(_source, Config.PumpkinItem, pumpkinsCount)
    if removedPumpkins then
        local playerPumpkins = getPlayerPumpkins(plyIdentifier)
        TriggerClientEvent('ox_lib:notify', _source, {
            id = 'halloween',
            title = 'Halloween',
            description = ('You gave %s pumpkins'):format(pumpkinsCount),
            duration = 5000,
            type = 'success',
        })
        if playerPumpkins > 0 then
            MySQL.update('UPDATE halloween_leaderboard SET pumpkins = pumpkins + ? WHERE identifier = ?', {pumpkinsCount, plyIdentifier})
        else
            local playerDiscord = fetchUserDiscord(_source)
            MySQL.insert('INSERT INTO halloween_leaderboard (identifier, pumpkins, name, avatar) VALUES (?, ?, ?, ?)', {plyIdentifier, pumpkinsCount, playerDiscord.name, playerDiscord.image})
        end
    end
end)

lib.callback.register('p_halloween:fetchLeaderboard', function(source)
    local _source = source
    local plyIdentifier = Core.GetPlayerIdentifier(_source)
    if not plyIdentifier then
        return
    end

    local leaderboard = MySQL.query.await('SELECT * FROM halloween_leaderboard ORDER by pumpkins DESC LIMIT 7')
    local row = MySQL.single.await('SELECT * FROM halloween_leaderboard WHERE identifier = ?', {plyIdentifier})
    if not row then
        local playerDiscord = fetchUserDiscord(_source)
        row = {pumpkins = 0, id = #leaderboard + 1, name = playerDiscord.name, avatar = playerDiscord.image}
    end

    return {leaderboard = leaderboard, stats = row}
end)