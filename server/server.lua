RegisterNetEvent('server:SpawnNPCAtPlayer')
AddEventHandler('server:SpawnNPCAtPlayer', function(playerCoords)
    local npcModel = Config.PedModels[math.random(1, #Config.PedModels)] 

    local spawnCoords = {
        x = playerCoords.x + math.random(-3, 3),
        y = playerCoords.y + math.random(-3, 3),
        z = playerCoords.z
    }

    TriggerClientEvent('ClientRequestSpawnNPC', source, npcModel, spawnCoords)
end)
