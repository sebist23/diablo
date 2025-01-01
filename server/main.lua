-- server/main.lua

local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local blipZone = {x = 200.0, y = 200.0, z = 20.0, radius = 50.0}
local jailTime = 60 -- 1 minute in seconds
local requiredPlaytime = 3600 -- 1 hour in seconds

-- Initialize oxmysql
local MySQL = exports.oxmysql
if not MySQL then
    print("Error: oxmysql not initialized correctly.")
end

-- Create a blip visible to all players
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        TriggerClientEvent('pekehoras:createBlip', -1, blipZone)
    end
end)

-- Track player playtime
local playerPlaytime = {}

AddEventHandler('playerConnecting', function()
    local playerId = source
    playerPlaytime[playerId] = 0
end)

AddEventHandler('playerDropped', function()
    local playerId = source
    savePlaytimeToDatabase(playerId)
    playerPlaytime[playerId] = nil
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- every second
        for playerId, time in pairs(playerPlaytime) do
            playerPlaytime[playerId] = time + 1
        end
    end
end)

-- Save playtime to database
function savePlaytimeToDatabase(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        local identifier = xPlayer.getIdentifier()
        local playtime = playerPlaytime[playerId] or 0
        MySQL.update('INSERT INTO player_playtime (identifier, playtime) VALUES (?, ?) ON DUPLICATE KEY UPDATE playtime = playtime + ?', {identifier, playtime, playtime}, function(affectedRows)
            if affectedRows > 0 then
                print("Playtime updated for player: " .. identifier)
            else
                print("Failed to update playtime for player: " .. identifier)
            end
        end)
    end
end

-- Check if player leaves the blip zone
RegisterServerEvent('pekehoras:checkPlayerZone')
AddEventHandler('pekehoras:checkPlayerZone', function(isInZone)
    local playerId = source
    if not isInZone then
        local playtime = playerPlaytime[playerId] or 0
        if playtime < requiredPlaytime then
            sendPlayerToJail(playerId)
        end
    end
end)

-- Jail system
function sendPlayerToJail(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        xPlayer.setCoords(vector3(0, 0, 0)) -- Example jail location
        TriggerClientEvent('pekehoras:notify', playerId, 'You have been jailed for not playing enough time.')
        Citizen.Wait(jailTime * 1000)
        xPlayer.setCoords(vector3(200, 200, 20)) -- Release location
        TriggerClientEvent('pekehoras:notify', playerId, 'You have been released from jail.')
    else
        print("Error: Player not found for jailing.")
    end
end