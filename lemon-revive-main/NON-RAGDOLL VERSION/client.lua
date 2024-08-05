-- client.lua

local isDead = false
local isNearDeath = false
local nearDeathTime = 0
local isRagdoll = false

-- Define hospital locations
local hospitalLocations = {
    {x = 300.0, y = -600.0, z = 43.0},  -- Example coordinates, replace with actual ones
    {x = -500.0, y = -300.0, z = 34.0},
    {x = 1150.0, y = -1520.0, z = 34.0},
    -- Add more hospitals as needed
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local playerPed = PlayerPedId()
        local playerHealth = GetEntityHealth(playerPed)
        
        if playerHealth <= Config.NearDeathHealthThreshold and not isNearDeath and not isDead then
            isNearDeath = true
            nearDeathTime = GetGameTimer()
            TriggerEvent('nearDeathEffect')
        elseif playerHealth > Config.NearDeathHealthThreshold and isNearDeath then
            isNearDeath = false
            StopScreenEffect('DeathFailOut')
        end

        if playerHealth <= 0 and not isDead then
            isDead = true
            TriggerEvent('playerDied')
        end

        if isDead then
            HandleDeathInput()
            AllowCameraMovement()
        end

        if isRagdoll then
            if IsControlJustPressed(0, 32) or IsControlJustPressed(0, 33) or IsControlJustPressed(0, 34) or IsControlJustPressed(0, 35) then
                ClearPedTasksImmediately(playerPed)
                isRagdoll = false
            end
        end
    end
end)

RegisterNetEvent('nearDeathEffect')
AddEventHandler('nearDeathEffect', function()
    StartScreenEffect('DeathFailOut', 0, true)
    Citizen.Wait(Config.NearDeathEffectDuration * 1000)
    if isNearDeath then
        SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, false, false, false)
    end
end)

RegisterNetEvent('playerDied')
AddEventHandler('playerDied', function()
    SetEntityHealth(PlayerPedId(), 0)
    isDead = true
    SendNUIMessage({action = 'show'})
end)

function HandleDeathInput()
    if IsControlJustPressed(0, 38) then -- E key
        revivePlayer()
    elseif IsControlJustPressed(0, 22) then -- Space bar
        revivePlayer()
    elseif IsControlJustPressed(0, 45) then -- R key
        respawnPlayer()
    end
end

function AllowCameraMovement()
    EnableControlAction(0, 1, true) -- LookLeftRight
    EnableControlAction(0, 2, true) -- LookUpDown
    DisableControlAction(0, 32, true) -- Move Up
    DisableControlAction(0, 33, true) -- Move Down
    DisableControlAction(0, 34, true) -- Move Left
    DisableControlAction(0, 35, true) -- Move Right
end

function revivePlayer()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, 0.0, true, false)
    SetEntityHealth(playerPed, 200)
    isDead = false
    isNearDeath = false
    isRagdoll = false
    StopScreenEffect('DeathFailOut')
    SendNUIMessage({action = 'hide'})
end

function respawnPlayer()
    local playerPed = PlayerPedId()
    local nearestHospital = GetNearestHospitalLocation()
    if nearestHospital then
        NetworkResurrectLocalPlayer(nearestHospital.x, nearestHospital.y, nearestHospital.z, 0.0, true, false)
        SetEntityHealth(playerPed, 200)
        isDead = false
        isNearDeath = false
        isRagdoll = false
        StopScreenEffect('DeathFailOut')
        SendNUIMessage({action = 'hide'})
    else
        -- Fallback in case no hospital is found
        local defaultLocation = {x = 200.0, y = 200.0, z = 100.0}
        NetworkResurrectLocalPlayer(defaultLocation.x, defaultLocation.y, defaultLocation.z, 0.0, true, false)
        SetEntityHealth(playerPed, 200)
        isDead = false
        isNearDeath = false
        isRagdoll = false
        StopScreenEffect('DeathFailOut')
        SendNUIMessage({action = 'hide'})
    end
end

function GetNearestHospitalLocation()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearestHospital = nil
    local minDistance = math.huge
    
    for _, hospital in ipairs(hospitalLocations) do
        local hospitalCoords = vector3(hospital.x, hospital.y, hospital.z)
        local distance = #(playerCoords - hospitalCoords)
        
        if distance < minDistance then
            minDistance = distance
            nearestHospital = hospitalCoords
        end
    end
    
    return nearestHospital
end