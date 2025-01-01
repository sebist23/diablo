-- client/main.lua

local blip = nil

-- Listen for the server event to create a blip
RegisterNetEvent('diablo:createBlip')
AddEventHandler('diablo:createBlip', function(blipZone)
    -- Remove existing blip if it exists
    if blip then
        RemoveBlip(blip)
    end

    -- Create a new blip
    blip = AddBlipForRadius(blipZone.x, blipZone.y, blipZone.z, blipZone.radius)

    -- Set blip properties
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, 1) -- Red color
    SetBlipAlpha(blip, 128) -- Semi-transparent

    -- Create a blip marker on the map
    local blipMarker = AddBlipForCoord(blipZone.x, blipZone.y, blipZone.z)
    SetBlipSprite(blipMarker, 1) -- Standard blip
    SetBlipDisplay(blipMarker, 4) -- Display on map and minimap
    SetBlipScale(blipMarker, 1.0)
    SetBlipColour(blipMarker, 1) -- Red color
    SetBlipAsShortRange(blipMarker, true)

    -- Set blip name
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Restricted Zone")
    EndTextCommandSetBlipName(blipMarker)
end)

-- Function to check if player is in the blip zone
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - vector3(blipZone.x, blipZone.y, blipZone.z))

        -- Trigger server event to check if player is in the zone
        TriggerServerEvent('diablo:checkPlayerZone', distance <= blipZone.radius)
    end
end)
