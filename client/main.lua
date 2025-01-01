-- client/main.lua

-- Function to create a blip on the map
Citizen.CreateThread(function()
    -- Define the coordinates for the blip
    local blipCoords = vector3(200.0, 200.0, 20.0) -- Example coordinates, adjust as needed

    -- Create the blip
    local blip = AddBlipForCoord(blipCoords.x, blipCoords.y, blipCoords.z)

    -- Set blip properties
    SetBlipSprite(blip, 1) -- Set the blip icon (1 is a default icon, change as needed)
    SetBlipDisplay(blip, 4) -- Set the display type
    SetBlipScale(blip, 1.0) -- Set the scale of the blip
    SetBlipColour(blip, 2) -- Set the color of the blip (2 is green, change as needed)
    SetBlipAsShortRange(blip, true) -- Make the blip short range

    -- Set the blip name
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("My Blip") -- Name of the blip
    EndTextCommandSetBlipName(blip)
end)
