local ragdollKey = 74 -- Key code for "H"
local isRagdoll = false -- State variable to track ragdoll status

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- Prevent blocking

        local playerPed = PlayerPedId()

        -- Check if the "H" key is pressed
        if IsControlJustPressed(1, ragdollKey) then
            if playerPed then
                -- Check if the player is not in a vehicle
                if not IsPedInAnyVehicle(playerPed, false) then
                    if not isRagdoll then
                        -- Activate ragdoll effect
                        SetPedToRagdoll(playerPed, -1, -1, 0, false, false, false)
                        isRagdoll = true
                        print("Ragdoll activated") -- Debug message
                    else
                        -- Deactivate ragdoll effect
                        ClearPedTasksImmediately(playerPed) -- Clear any ongoing tasks
                        -- Smoothly transition to standing
                        TaskPlayAnim(playerPed, "amb@medic@standing@tend@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
                        isRagdoll = false
                        print("Ragdoll deactivated") -- Debug message
                    end
                else
                    print("Cannot activate ragdoll while in a vehicle") -- Debug message
                end
            else
                print("PlayerPedId() returned nil") -- Debug message
            end
        end

        -- Optional: Ensure the player remains in ragdoll mode
        if isRagdoll then
            if not IsPedRagdoll(playerPed) then
                SetPedToRagdoll(playerPed, -1, -1, 0, false, false, false)
            end
        end
    end
end)