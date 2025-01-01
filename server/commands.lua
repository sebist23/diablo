-- server/commands.lua

local oxmysql = require('oxmysql')
local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

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

-- Register the /horas command
ESX.RegisterCommand('horas', 'user', function(xPlayer, args, showError)
    local identifier = xPlayer.getIdentifier()
    getPlayerHours(identifier, function(hours)
        -- Send a message to the player with their hours
        xPlayer.showNotification('You have ' .. hours .. ' hours.')
    end)
end, false, {help = 'Check your stored hours'})

