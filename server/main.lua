-- server/main.lua

local oxmysql = require('oxmysql')
local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Define the blip area and jail location
local blipArea = {x = 200.0, y = 200.0, z = 20.0, radius = 50.0}
local jailLocation = {x = 1800.0, y = 2600.0, z = 45.0}

-- Function to get player hours from the database
local function getPlayerHours(identifier, callback)
    oxmysql.query('SELECT hours FROM users WHERE identifier = ?', {identifier}, function(result)
        if result[1] then
            callback(result[1].hours)
        else
            callback(0)
        end
    end)
end

-- Function to update player hours in the database
local function updatePlayerHours(identifier, hours)
    oxmysql.update('UPDATE users SET hours = ? WHERE identifier = ?', {hours, identifier})
end

-- Function to check if a player is within the blip area
local function isPlayerInBlipArea(playerCoords)
    local distance = #(vector3(blipArea.x, blipArea.y, blipArea.z) - playerCoords)
    return distance <= blipArea.radius
end

-- Event to track player hours
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Check every minute
        local players = ESX.GetPlayers()
        for _, playerId in ipairs(players) do
            local xPlayer = ESX.GetPlayerFromId(playerId)
            local identifier = xPlayer.getIdentifier()
            getPlayerHours(identifier, function(hours)
                hours = hours + 1 / 60 -- Increment hours by 1 minute
                updatePlayerHours(identifier, hours)
            end)
        end
    end
end)

-- Event to handle player leaving the blip area
RegisterServerEvent('playerDropped')
AddEventHandler('playerDropped', function(reason)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local identifier = xPlayer.getIdentifier()
    local playerCoords = xPlayer.getCoords()

    if not isPlayerInBlipArea(playerCoords) then
        getPlayerHours(identifier, function(hours)
            if hours < 1 then
                -- Send player to jail
                xPlayer.setCoords(jailLocation.x, jailLocation.y, jailLocation.z)
                Citizen.Wait(60000) -- Jail time for 1 minute
                -- Release player from jail
                xPlayer.setCoords(blipArea.x, blipArea.y, blipArea.z)
            end
        end)
    end
end)
