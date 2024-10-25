local prompt 
local isPromptSetup = false 
local pedModelsLoaded = false 
local npcEntities = {} 
local promptCooldown = false

function PreloadPedModels()
    if not pedModelsLoaded then
        for _, pedModel in ipairs(Config.PedModels) do
            RequestModel(pedModel)
            while not HasModelLoaded(pedModel) do
                Citizen.Wait(10)
            end
        end
        pedModelsLoaded = true
    end
end

Citizen.CreateThread(function()
    PreloadPedModels()
end)

local function setupPrompt(propCoords)
    if not isPromptSetup and not promptCooldown then 
        prompt = PromptRegisterBegin()
        PromptSetControlAction(prompt, Config.keys.interact)
        PromptSetText(prompt, CreateVarString(10, "LITERAL_STRING", Config.Messages.PromptInteract)) 
        PromptSetEnabled(prompt, true)
        PromptSetVisible(prompt, true)
        PromptRegisterEnd(prompt)

        Citizen.InvokeNative(0xAE84C5EE2C384FB3, prompt, propCoords.x, propCoords.y, propCoords.z)
        Citizen.InvokeNative(0x0C718001B77CA468, prompt, 2.5)
        isPromptSetup = true
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerCoords = GetEntityCoords(PlayerPedId())
        local promptActive = false
        local currentPropCoords = nil

        for _, prop in ipairs(Config.Props) do
            local propEntity = GetClosestObjectOfType(playerCoords, 2.5, GetHashKey(prop), false)

            if propEntity ~= 0 then
                local propCoords = GetEntityCoords(propEntity)

                if Vdist(playerCoords, propCoords) < 2.5 and not promptCooldown then 
                    currentPropCoords = propCoords
                    setupPrompt(propCoords)
                    promptActive = true

                    if IsControlJustPressed(0, Config.keys.interact) then
                        local playerPed = PlayerPedId()
                        Anim(playerPed, 'script_mp@last_round@photos', 'pose1_m04')
                        
                        promptCooldown = true
                        Citizen.CreateThread(function()
                            Citizen.Wait(10000) 
                            promptCooldown = false 
                        end)
                    end
                end
            end
        end

        if not promptActive then
            isPromptSetup = false
            prompt = nil
        end
    end
end)

function Anim(actor, dict, body, duration, flags, introtiming, exittiming)
    Citizen.CreateThread(function()
        RequestAnimDict(dict)
        local dur = duration or -1
        local flag = flags or 1
        local intro = tonumber(introtiming) or 1.0
        local exit = tonumber(exittiming) or 2.0
        local timeout = 5

        while (not HasAnimDictLoaded(dict) and timeout > 0) do
            timeout = timeout - 1
            Citizen.Wait(300)
        end

        TaskPlayAnim(actor, dict, body, intro, exit, dur, flag, 1, false, false, false, 0, true)
        Citizen.Wait(10000) 

        ClearPedTasks(actor)
        TriggerEvent('endPrayerAnimation') 
    end)
end

RegisterNetEvent('endPrayerAnimation')
AddEventHandler('endPrayerAnimation', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    TriggerServerEvent('server:SpawnNPCAtPlayer', playerCoords)
end)

RegisterNetEvent('ClientRequestSpawnNPC')
AddEventHandler('ClientRequestSpawnNPC', function(npcModel, spawnCoords)
    local npcModelHash = GetHashKey(npcModel)

    RequestModel(npcModelHash)
    while not HasModelLoaded(npcModelHash) do
        Citizen.Wait(100)
    end

    local npc = CreatePed(npcModelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)

    if DoesEntityExist(npc) then
        table.insert(npcEntities, npc)
        SetEntityVisible(npc, true)
        SetEntityAlpha(npc, 128, false)
        SetEntityInvincible(npc, true) 
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true)  -- SetRandomOutfitVariation
        Citizen.InvokeNative(0x1794B4FCC84D812F, npc, true)
        NetworkRegisterEntityAsNetworked(npc) 
    
        TaskWanderInArea(npc, spawnCoords.x, spawnCoords.y, spawnCoords.z, 50.0, 100.0, 200.0)

        Citizen.CreateThread(function()
            Citizen.Wait(40000)
            if DoesEntityExist(npc) then
                DeleteEntity(npc)
            end
        end)
    else
    end
end)
