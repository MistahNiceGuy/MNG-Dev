local QBCore = exports['qb-core']:GetCoreObject()
local AlertDelay = 0

CreateThread(function()
    CreateTarget()
end)

RegisterNetEvent('mng-atmrobbery:client:StartMiniGame', function(NetID, HackType) --convert to net event
    local count = 0
    lib.callback('mng-atmrobbery:server:GetUSBInfo', false, function(USB)
        exports['boii_minigames']:pincode({
            style = 'default', -- Style template
            difficulty = USB.Difficulty, -- Difficuly; increasing the value increases the amount of numbers in the pincode; level 1 = 4 number, level 2 = 5 numbers and so on // The ui will comfortably fit 10 numbers (level 6) this should be more than enough
            guesses = USB.Guesses -- Amount of guesses allowed before fail
        }, function(success) -- Game callback
            if not success then
                count += 1
            end
            if count <= 1 then
                TriggerServerEvent('mng-atmrobbery:server:'..USB.ServerEvent, NetID, success)
            end
        end)
    end, HackType)
end)

RegisterNetEvent('mng-atmrobbery:client:Alert', function(ID)
    local Delay = 0
    local Ent = NetworkGetEntityFromNetworkId(ID)
    if Entity(Ent).state.Delay ~= nil then
        Delay = Entity(Ent).state.Delay
    end
    SetTimeout(Delay, function() exports['ps-dispatch']:ATMRobbery() end)
end)

RegisterNetEvent('mng-atmrobbery:client:BFCountDown', function(ID)
    local Time = 10 --Config.BruteForceTime * 60
    local Ent = NetworkGetEntityFromNetworkId(ID)
    while Time > 0 do
        lib.showTextUI('Time Remaining: '..Time..' Seconds')
        Wait(1000)
        Time -= 1
        if Time <= 0 then
            lib.hideTextUI()
            lib.notify({
                title = 'Brute Force Successful',
                description = 'System Penetrated',
                type = 'success'
            })
            Entity(Ent).state:set('Reward', true, true)
        end
    end
end)

function USBAnim()
    LoadAnimation('anim@mp_atm@enter')
    TaskPlayAnim(cache.ped, 'anim@mp_atm@enter', 'enter', 6.0, -6.0, -1, 16, 0, 0, 0, 0)
    Wait(1400)
    LoadAnimation('anim@heists@fleeca_bank@scope_out@cashier_loop')
    TaskPlayAnim(cache.ped, 'anim@heists@fleeca_bank@scope_out@cashier_loop', 'cashier_loop', 6.0, -6.0, -1, 16, 0, 0, 0, 0)
end

function LoadAnimation(dict)
    RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do Wait(10) end
end

function CreateTarget()
    for i = 1, #Config.ATMModels do
        exports.interact:AddModelInteraction({
            model = Config.ATMModels[i],
            offset = vec3(0.0, 0.0, 1.0),
            distance = 3.0,
            interactDst = 2.0,
            options = {
                {
                    label = 'Use ATM',
                    action = function(entity, coords, args)
                        NetworkRegisterEntityAsNetworked(entity)
                        local netID = NetworkGetNetworkIdFromEntity(entity)
                        TriggerServerEvent('mng-atmrobbery:server:OpenATMUI', netID)
                    end,
                },
                {
                    label = 'Collect Cash',
                    canInteract = function(entity, coords, args)
                        return Entity(entity).state.Reward
                      end,
                    action = function(entity, coords, args)
                        if lib.progressCircle({
                            duration = 5000,
                            label = 'Collecting USB',
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                                move = true,
                                combat = true,
                                sprint = true,
                            },
                            anim = {
                                dict = 'mp_missheist_ornatebank',
                                clip = 'stand_cash_in_bag_loop',
                            }
                        })
                        then
                            ClearPedTasksImmediately(cache.ped)
                            NetworkRegisterEntityAsNetworked(entity)
                            local netID = NetworkGetNetworkIdFromEntity(entity)
                            TriggerServerEvent('mng-atmrobbery:server:Finish', netID)
                        end
                    end,
                },
                {
                    label = 'Collect KeyLogger',
                    canInteract = function(entity, coords, args)
                        return Entity(entity).state.KLCollect
                      end,
                    action = function(entity, coords, args)
                        if lib.progressCircle({
                            duration = 5000,
                            label = 'Collecting USB',
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                                move = true,
                                combat = true,
                                sprint = true,
                            },
                            anim = {
                                dict = 'anim@mp_atm@enter',
                                clip = 'enter',
                            }
                        })
                        then
                            ClearPedTasksImmediately(cache.ped)
                            NetworkRegisterEntityAsNetworked(entity)
                            local netID = NetworkGetNetworkIdFromEntity(entity)
                            TriggerServerEvent('mng-atmrobbery:server:CollectKL', netID)
                        end
                    end,
                },
                {
                    label = 'Insert BruteForce USB',
                    canInteract = function(entity, coords, args)
                        return exports.ox_inventory:Search('count', 'bruteforce') > 0 and not Entity(entity).state.Keylogged
                      end,
                    action = function(entity, coords, args)
                        SetTimeout(0, function() USBAnim() end)
                        if lib.progressCircle({
                            duration = 5000,
                            label = 'Inserting USB',
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                                move = true,
                                combat = true,
                                sprint = true,
                            },
                        })
                        then
                            ClearPedTasksImmediately(cache.ped)
                            NetworkRegisterEntityAsNetworked(entity)
                            local netID = NetworkGetNetworkIdFromEntity(entity)
                            TriggerServerEvent('mng-atmrobbery:server:BruteForce', netID, coords)
                        end
                    end,
                },
                {
                    label = 'Insert DDOS USB',
                    canInteract = function(entity, coords, args)
                        return exports.ox_inventory:Search('count', 'ddos') > 0 and not Entity(entity).state.Keylogged
                      end,
                    action = function(entity, coords, args)
                        SetTimeout(0, function() USBAnim() end)
                        if lib.progressCircle({
                            duration = 5000,
                            label = 'Inserting USB',
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                                move = true,
                                combat = true,
                                sprint = true,
                            },
                        })
                        then
                            ClearPedTasksImmediately(cache.ped)
                            NetworkRegisterEntityAsNetworked(entity)
                            local netID = NetworkGetNetworkIdFromEntity(entity)
                            TriggerServerEvent('mng-atmrobbery:server:DDOS', netID, coords)
                        end
                    end,
                },
                {
                    label = 'Insert KeyLogger USB',
                    canInteract = function(entity, coords, args)
                        return exports.ox_inventory:Search('count', 'keylogger') > 0 and not Entity(entity).state.KLToggle
                    end,
                    action = function(entity, coords, args)
                        SetTimeout(0, function() USBAnim() end)
                        if lib.progressCircle({
                            duration = 5000,
                            label = 'Inserting USB',
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                                move = true,
                                combat = true,
                                sprint = true,
                            },
                        })
                        then
                            ClearPedTasksImmediately(cache.ped)
                            NetworkRegisterEntityAsNetworked(entity)
                            local netID = NetworkGetNetworkIdFromEntity(entity)
                            TriggerServerEvent('mng-atmrobbery:server:KeyLogger', netID, coords)
                        end
                    end,
                },
                {
                    label = 'Insert Code Injector USB',
                    canInteract = function(entity, coords, args)
                        return exports.ox_inventory:Search('count', 'codeinjector') > 0 and not Entity(entity).state.Keylogged
                    end,
                    action = function(entity, coords, args)
                        SetTimeout(0, function() USBAnim() end)
                        if lib.progressCircle({
                            duration = 5000,
                            label = 'Inserting USB',
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                                move = true,
                                combat = true,
                                sprint = true,
                            },
                        })
                        then
                            ClearPedTasksImmediately(cache.ped)
                            NetworkRegisterEntityAsNetworked(entity)
                            local netID = NetworkGetNetworkIdFromEntity(entity)
                            TriggerServerEvent('mng-atmrobbery:server:CodeInjector', netID, coords)
                        end
                    end,
                },
            }
        })
    end
end

RegisterNetEvent('mng-atmrobbery:client:KeyLoggerCD', function(ID)
    local Ent = NetworkGetEntityFromNetworkId(ID)
    SetTimeout(0, function() KeyLoggerCD(Ent) end)
end)

function KeyLoggerCD(Ent)
    local Loop = true
    while Loop do
        lib.callback('mng-atmrobbery:server:GetKLTime', false, function(CurrentTime)
            print(Entity(Ent).state.Keylogger)
            print(CurrentTime)
            if CurrentTime >= Entity(Ent).state.Keylogger + Config.KeyLoggerTime * 60 then
                Entity(Ent).state:set('KLCollect', true, true)
                Loop = false
            end
        end, ID)
        Wait(60000)
    end
end

exports.ox_inventory:displayMetadata({
    Ready = 'System Breached',
    Uses = 'Remaining Attempts'
})