-- server.lua

QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('playerDied')
AddEventHandler('playerDied', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    -- You can add custom logic here if needed
end)

RegisterCommand('revive', function(source, args, rawCommand)
    if source == 0 then -- If command is run from server console
        local targetId = tonumber(args[1])
        if targetId then
            TriggerClientEvent('playerRevived', targetId)
        else
            print("Usage: /revive [playerID]")
        end
    else
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer and xPlayer.job.name == 'police' then
            local targetId = tonumber(args[1])
            if targetId then
                TriggerClientEvent('playerRevived', targetId)
            else
                print("Usage: /revive [playerID]")
            end
        else
            TriggerClientEvent('QBCore:Notify', source, "You don't have permissions to use this command.", 'error')
        end
    end
end, false)
