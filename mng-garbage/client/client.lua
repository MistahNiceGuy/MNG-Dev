local QBCore = exports['qb-core']:GetCoreObject()
local blips = {}
local Boss = nil
local HasBag = false
local PickupCheck = false
local LoadCheck = false
local BagObject = nil
local Truck = nil

function CreatePeds()
    Boss = exports['rep-talkNPC']:CreateNPC({
        npc = 's_m_y_garbage',
        coords = Config.Ped.coords,
        name = 'Thomas Plant',
        tag = 'Garbage Supervisor',
        animScenario = 'WORLD_HUMAN_CLIPBOARD',
        position = "Garbage Supervisor",
        color = "#00736F",
        startMSG = 'Hello, how can I assist you?'
    }, 
        {
            [1] = {
                label = "How does this job work?",
                shouldClose = false,
                action = function()
                    exports['rep-talkNPC']:updateMessage("Your group will be given several locations on a route to gather garbage. Approach the dumpster to gather the trash bag and then bring it to the back of your truck to deposit it.")
                end
            },
            [2] = {
                label = "Start / Finish Work.",
                shouldClose = false,
                action = function()
                    exports['rep-talkNPC']:changeDialog( "You can finish your route early and still receive payment for each stop you finished.",
                        {
                            [1] = {
                                label = "Start Work.",
                                shouldClose = true,
                                action = function()
                                    TriggerServerEvent('mng-garbage:server:CanStart')
                                end
                            },
                            [2] = {
                                label = "Finish Work",
                                shouldClose = true,
                                action = function()
                                    TriggerServerEvent('mng-garbage:server:EndJob')
                                end
                            }
                        }
                    )
                end
            },
            [3] = {
                label = "Exchange Recyclable Materials",
                shouldClose = true,
                action = function()
                    Exchange()
                end
            },
            [4] = {
                label = "Goodbye",
                shouldClose = true,
                action = function()
                    TriggerEvent('rep-talkNPC:client:close')
                end
            }
        })
    end
function CreateBlips()
    for k,v in pairs(Config.PedList) do
        if v.blipInfo.enable then
            blips[k] = AddBlipForCoord(v.coords)
            SetBlipSprite(blips[k], v.blipInfo.sprite)
            SetBlipDisplay(blips[k], 4)
            SetBlipScale(blips[k], v.blipInfo.scale)
            SetBlipAsShortRange(blips[k], true)
            SetBlipColour(blips[k], v.blipInfo.color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(v.blipInfo.text)
            EndTextCommandSetBlipName(blips[k]) 
        end   
    end
end
CreateThread(function()
    CreateBlips()
    CreatePeds()
end)


function TrashZoneCheck()
    PickupCheck = true
    CreateThread(function()
        while PickupCheck do
            if IsControlJustPressed(0, 38) then
                GrabTrash()
                exports['qb-core']:KeyPressed(38)
                PickupCheck = false
                local ped = PlayerPedId()
            end
            Wait(1)
        end
    end)
end

function TruckZoneCheck()
    LoadCheck = true
    CreateThread(function()
        while LoadCheck do
            if IsControlJustPressed(0, 38) then
                TossTrash()
                exports['qb-core']:KeyPressed(38)
                LoadCheck = false
                local ped = PlayerPedId()
            end
            Wait(1)
        end
    end)
end

function LoadAnimation(dict)
    RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do Wait(10) end
end

function AnimBagCheck()
    CreateThread(function()
        while HasBag do
            local ped = PlayerPedId()
            if not IsEntityPlayingAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 3) then
                ClearPedTasksImmediately(ped)
                LoadAnimation('missfbi4prepp1')
                TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
            end
            Wait(200)
        end
    end)
end

function TakeBagAnim()
    local ped = PlayerPedId()
    LoadAnimation('missfbi4prepp1')
    TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
    BagObject = CreateObject(`prop_cs_rub_binbag_01`, 0, 0, 0, true, true, true)
    AttachEntityToEntity(BagObject, ped, GetPedBoneIndex(ped, 57005), 0.12, 0.0, -0.05, 220.0, 120.0, 0.0, true, true, false, true, 1, true)
    AnimBagCheck()
end

function DeliverBagCheck()
    local ped = PlayerPedId()
    LoadAnimation('missfbi4prepp1')
    TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_throw_garbage_man', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
    FreezeEntityPosition(ped, true)
    SetTimeout(1250, function()
        DetachEntity(BagObject, 1, false)
        DeleteObject(BagObject)
        TaskPlayAnim(ped, 'missfbi4prepp1', 'exit', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
        FreezeEntityPosition(ped, false)
        BagObject = nil
    end)
end

function TossTrash()
    if lib.progressCircle({
        duration = 3000,
        label = 'Tossing Trash',
        useWhileDead = false,
        allowRagdoll = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = true,
            sprint = true,
        },
    })  
    then 
        HasBag = false
        DeliverBagCheck()
        TriggerServerEvent('mng-garbage:server:UpdateBags')
    else
        HasBag = true
    end
end

RegisterNetEvent('mng-garbage:client:CreateTrashZone', function(Route)
    local Coords = Config.Locations[Route].coords
    exports.interact:AddInteraction({
        coords = vec3(Coords.x, Coords.y, Coords.z - 1.5),
        distance = 10.0,
        interactDst = 1.5,
        id = 'Garbage'..Route,
        options = {
             {
                label = 'Collect Trash',
                canInteract = function()
                    if HasBag then
                        return false
                    end
                    return true
                end,
                action = function()
                    GrabTrash()
                end,
            },
        }
    })
end)

RegisterNetEvent('mng-garbage:client:CreateTruckZone', function(Veh)
    Truck = NetworkGetEntityFromNetworkId(Veh)
    exports.interact:AddEntityInteraction({
        netId = Veh,
        name = 'Toss Trash',
        id = 'Toss Trash',
        distance = 2.0,
        interactDst = 1.0,
        offset = vec3(0.0, -5.0, 0.5),
        options = {
            {
                label = 'Toss Trash',
                canInteract = function()
                    if HasBag then
                        return true
                    end
                    return false
                end,
                action = function()
                    TossTrash()
                end,
            },
        }
    })
end)

function GrabTrash()
    local ped = PlayerPedId()
    if lib.progressCircle({
        duration = 3000,
        label = 'Grabbing Trash',
        position = 'bottom',
        useWhileDead = false,
        allowRagdoll = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = true,
            sprint = true,
        },
        anim = {
            dict = "mini@repair",
            clip = "fixing_a_ped",
            flag = 16,
        },
    })  
    then 
        HasBag = true
        ClearPedTasksImmediately(ped)
        TakeBagAnim()
    else
        HasBag = false
        ClearPedTasksImmediately(ped)
    end
end

RegisterNetEvent('mng-garbage:client:ClearStatus', function()
    local ped = PlayerPedId()
    if HasBag then
        ClearPedTasksImmediately(ped)
        HasBag = false
        DetachEntity(BagObject, 1, false)
        DeleteObject(BagObject)
    end
end)

RegisterNetEvent('mng-garbage:client:ClearZone', function(Route)
    exports.interact:RemoveInteraction('Garbage'..Route)
end)

RegisterNetEvent('mng-garbage:client:SetTruck', function(Veh)
    Truck = NetworkGetEntityFromNetworkId(Veh)
    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(Truck))
    exports['ps-fuel']:SetFuel(Truck, 100.0)
end)

function ExchangeMenu()
    local ExchangeMenu = {
        {
            header = "Exchange Recyclable Materials",
            isMenuHeader = true
        }
    }
    ExchangeMenu[#ExchangeMenu+1] = {
        header = 'Exchange For Iron',
        params = {
            event = "mng-garbage:client:ExchangeMaterial",
            args = {
                item = 'Config.PayoutItem',
                reward = 'iron',
            }
        }
    }
    ExchangeMenu[#ExchangeMenu+1] = {
        header = 'Exchange For Steel',
        params = {
            event = "mng-garbage:client:ExchangeMaterial",
            args = {
                item = 'Config.PayoutItem',
                reward = 'steel',
            }
        }
    }
    ExchangeMenu[#ExchangeMenu+1] = {
        header = 'Exchange For Rubber',
        params = {
            event = "mng-garbage:client:ExchangeMaterial",
            args = {
                item = 'Config.PayoutItem',
                reward = 'rubber',
            }
        }
    }
    ExchangeMenu[#ExchangeMenu+1] = {
        header = 'Exchange For Glass',
        params = {
            event = "mng-garbage:client:ExchangeMaterial",
            args = {
                item = 'Config.PayoutItem',
                reward = 'glass',
            }
        }
    }
    ExchangeMenu[#ExchangeMenu+1] = {
        header = 'Exchange For Plastic',
        params = {
            event = "mng-garbage:client:ExchangeMaterial",
            args = {
                item = 'Config.PayoutItem',
                reward = 'plastic',
            }
        }
    }
    ExchangeMenu[#ExchangeMenu+1] = {
        header = 'Exchange For Metal Scrap',
        params = {
            event = "mng-garbage:client:ExchangeMaterial",
            args = {
                item = 'Config.PayoutItem',
                reward = 'metalscrap',
            }
        }
    }
    ExchangeMenu[#ExchangeMenu+1] = {
        header = 'Exchange For Copper',
        params = {
            event = "mng-garbage:client:ExchangeMaterial",
            args = {
                item = 'Config.PayoutItem',
                reward = 'copper',
            }
        }
    }
    ExchangeMenu[#ExchangeMenu+1] = {
        header = 'Exchange For Aluminum',
        params = {
            event = "mng-garbage:client:ExchangeMaterial",
            args = {
                item = 'Config.PayoutItem',
                reward = 'aluminum',
            }
        }
    }
    ExchangeMenu[#ExchangeMenu+1] = {
        header = 'Close Menu',
    txt = '',
    params = {
        event = "qb-menu:closeMenu",
    }
}
exports['qb-menu']:openMenu(ExchangeMenu)
end

function Exchange()
    local input = lib.inputDialog('Dialog title', {
        {type = 'select', label = 'Material select', description = 'Select which material you wish to exchange for.', required = true, options = {
            {value = 'iron',
            label = 'Iron',},
            {value = 'steel',
            label = 'Steel',},
            {value = 'rubber',
            label = 'Rubber',},
            {value = 'glass',
            label = 'Glass',},
            {value = 'plastic',
            label = 'Plastic',},
            {value = 'metalscrap',
            label = 'Metal Scrap',},
            {value = 'copper',
            label = 'Copper',},
            {value = 'aluminum',
            label = 'Aluminum',},
        }},
        {type = 'number', label = 'How many?', description = 'Enter the number of materials you wish to exchange.', required = true, icon = 'hashtag'}
      })
      if input[1] and input[2] then
        ExchangeMaterial(input[1], input[2])
      end
end

function ExchangeMaterial(mat, num)
    lib.callback('mng-garbage:server:HasItem', false, function(HasItem)
        if HasItem then
            if lib.progressCircle({
                duration = 3000,
                label = 'Exchanging Materials',
                position = 'bottom',
                useWhileDead = false,
                allowRagdoll = false,
                allowCuffed = false,
                allowFalling = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                    mouse = true,
                    sprint = true,
                },
                anim = {
                    dict = "mini@repair",
                    clip = "fixing_a_ped",
                    flag = 16,
                },
            })  
            then 
                TriggerServerEvent('mng-garbage:server:MaterialExchange', num, mat)
            end
        else
            lib.notify({
                description = 'You do not have enough materials to exchange!',
                type = 'error'
            })
        end
    end, Config.PayoutItem, num)
end

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
        DeleteEntity(Boss)
	end
end)