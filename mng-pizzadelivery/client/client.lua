local QBCore = exports['qb-core']:GetCoreObject()
local blips = {}
local objects = {}
local DeliveryVehicle = nil
local HasBox = false
local AllFinished = false
local CurrentBlip = nil
local Boss = nil

function CreatePeds()
        Boss = exports['rep-talkNPC']:CreateNPC({
        npc = Config.PedList[1].model,
        coords = vector4(Config.PedList[1].coords, Config.PedList[1].heading),
        name = 'Tony Pepperoni',
        tag = 'PzzaThis Manager',
        animScenario = 'WORLD_HUMAN_CLIPBOARD',
        position = "Pizza Manager",
        color = "#00736F",
        startMSG = 'Hello, how can I assist you?'
    }, 
        {
            [1] = {
                label = "How does this job work?",
                shouldClose = false,
                action = function()
                    exports['rep-talkNPC']:updateMessage("You will be provided a vehicle based on your experience to deliver pizzas, when you arrive at the delivery location, pickup the pizza from the back of the vehicle and take it to the persons door.")
                end
            },
            [2] = {
                label = "Start Working",
                shouldClose = true,
                action = function()
                    VehMenu()
                end
            },
            [3] = {
                label = "Stop Working",
                shouldClose = true,
                action = function()
                    TriggerServerEvent('mng-pizzadelivery:server:EndJob')
                end
            },
            [4] = {
                label = "Goodbye",
                shouldClose = true,
                action = function()
                    TriggerEvent('rep-talkNPC:client:close')
                end
            },
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

RegisterNetEvent('mng-pizzadelivery:client:PizzaMenu', function()
    local PizzaMenu = {
        {
            header = "Pizza Deliver",
            isMenuHeader = true
        }
    }
    PizzaMenu[#PizzaMenu+1] = {
        header = 'Open Level Menu',
        txt = "View Your Stats and Level",
        params = {
            event = "mng-pizzadelivery:client:ExpMenu",
        }
    }
    PizzaMenu[#PizzaMenu+1] = {
        header = 'Start Working',
        txt = "Get Your Delivery Route",
        params = {
            event = "mng-pizzadelivery:client:VehMenu",
        }
    }
    PizzaMenu[#PizzaMenu+1] = {
        header = 'End Work',
        txt = "End Your Route and Get Paid",
        params = {
            isServer = true,
            event = "mng-pizzadelivery:server:EndJob",
        }
    }
    PizzaMenu[#PizzaMenu+1] = {
        header = 'Close Menu',
    txt = '',
    params = {
        event = "qb-menu:closeMenu",
        }
    }
exports['qb-menu']:openMenu(PizzaMenu)
end)

function VehMenu()
    local Player = QBCore.Functions.GetPlayerData()
    local lvl = tonumber(Player.metadata["pizzalevel"])
    local exp = tonumber(Player.metadata["pizzaexp"])
    local Motorcycle = true
    local Car = true
    if lvl >= Config.Vehicles.Motorcycle.RequiredLevel then
        Motorcycle = false
    end
    if lvl >= Config.Vehicles.Car.RequiredLevel then
        Car = false
    end
    local VehMenu = {
        {
            header = "Level "..lvl,
            txt = 'Experience '..exp..' / '..Config.ExperiencePerLevel,
            isMenuHeader = true
        }
    }
    VehMenu[#VehMenu+1] = {
        header = 'Scooter',
        params = {
            isServer = true,
            event = "mng-pizzadelivery:server:StartJob",
            args = {vehicle = 'Scooter'},
        }
    }
    VehMenu[#VehMenu+1] = {
        header = 'MotorCycle',
        txt = 'Required Level '..Config.Vehicles.Motorcycle.RequiredLevel,
        disabled = Motorcycle,
        params = {
            isServer = true,
            event = "mng-pizzadelivery:server:StartJob",
            args = {vehicle = 'Motorcycle'},
        }
    }
    VehMenu[#VehMenu+1] = {
        header = 'Electric Car',
        txt = 'Required Level '..Config.Vehicles.Car.RequiredLevel,
        disabled = Car,
        params = {
            isServer = true,
            event = "mng-pizzadelivery:server:StartJob",
            args = {vehicle = 'Car'},
        }
    }
    VehMenu[#VehMenu+1] = {
        header = 'Close Menu',
    txt = '',
    params = {
        event = "qb-menu:closeMenu",
        }
    }
exports['qb-menu']:openMenu(VehMenu)
end

RegisterNetEvent('mng-pizzadelivery:client:handleProps', function(deliveries, car, status)
    DeliveryVehicle = NetworkGetEntityFromNetworkId(car)
    if status == 'create' then
        objects[1] =  CreateObject(`prop_pizza_box_01`, 0, 0, 0, true, true, true)
        AttachEntityToEntity(objects[1], DeliveryVehicle, 0, 0, -0.85, 0.33, 0, 0, 0.0, true, true, false, false, 1, true)
        if deliveries > 1 then
            for i = 2, deliveries do
                objects[i] =  CreateObject(`prop_pizza_box_01`, 0, 0, 0, true, true, true)
                AttachEntityToEntity(objects[i], objects[i - 1], 0, 0, 0, 0.06, 0, 0, 0.0, true, true, false, false, 1, true)
            end
        end
    elseif status == 'clear' then
        for i = 1, #objects do
            DeleteEntity(objects[i])
        end
        DeleteEntity(DeliveryVehicle)
    elseif status == 'delete' then
        DeleteEntity(objects[deliveries])
    end
end)

RegisterNetEvent('mng-pizzadelivery:client:setVeh', function(car, plate, deliveries, vehtype)
    TriggerEvent("vehiclekeys:client:SetOwner", plate)
    local MaxDeliveries = deliveries
    DeliveryVehicle = NetworkGetEntityFromNetworkId(car)
    exports['ps-fuel']:SetFuel(DeliveryVehicle, 100.0)
    exports.interact:AddEntityInteraction({
        netId = car,
        id = 'Pizza',
        distance = 2.2,
        interactDst = 1.2,
        ignoreLos = true,
        offset = vec3(0.0, -0.7, 0.4), -- optional
        options = {
            {
                label = 'Grab Pizza Box',
                action = function()
                    GrabBox(MaxDeliveries, vehtype)
                    MaxDeliveries = MaxDeliveries - 1
                end,
                canInteract = function()
                    if HasBox or AllFinished then
                        return false
                    end
                    return true
                end,
            },
        }
    })
end)

function LoadAnimation(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
end

function AnimBoxCheck()
    CreateThread(function()
        while HasBox do
            local ped = PlayerPedId()
            if not IsEntityPlayingAnim(ped, 'anim@heists@box_carry@', 'idle', 3) then
                ClearPedTasks(ped)
                LoadAnimation('anim@heists@box_carry@')
                TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
            end
            Wait(2000)
            if HasBox == false then
                StopAnimTask(ped, 'anim@heists@box_carry@', 'idle', 1.0)
            end
        end
    end)
end

function TakeBoxAnim(num, vehtype)
    local ped = PlayerPedId()
    if vehtype == 'Car' then
        objects[1] =  CreateObject(`prop_pizza_box_01`, 0, 0, 0, true, true, true)
        LoadAnimation('anim@heists@box_carry@')
        TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
        AttachEntityToEntity(objects[1], ped, GetPedBoneIndex(ped, 60309), 0.3, 0.16, 0.15, -130.0, 105.0, 5.0, true, true, false, true, 1, true)
        AnimBoxCheck()
    else
        LoadAnimation('anim@heists@box_carry@')
        TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
        AttachEntityToEntity(objects[num], ped, GetPedBoneIndex(ped, 60309), 0.3, 0.16, 0.15, -130.0, 105.0, 5.0, true, true, false, true, 1, true)
        AnimBoxCheck()
    end
end

function GrabBox(num, vehtype)
    if lib.progressCircle({
        duration = 3000,
        label = 'Grabbing Pizza Box',
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
    })
    then
        HasBox = true
        TakeBoxAnim(num, vehtype)
    else
        ClearPedTasks(cache.ped)
        HasBox = false
    end
end

function DeliverPizza(CurrentDelivery)
    local ped = PlayerPedId()
    if not HasBox then
        return
    end
    if lib.progressCircle({
        duration = 5000,
        label = 'Delivering pizza',
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
    })
    then
        HasBox = false
        ClearPedTasks(ped)
        DeleteEntity(objects[#objects])
        table.remove(objects)
        RemoveBlip(CurrentBlip)
        TriggerServerEvent('mng-pizzadelivery:server:UpdateDelivery')
        exports.interact:RemoveInteraction('Pizza'..CurrentDelivery)
        ClearPedSecondaryTask(PlayerPedId())
    end
end

RegisterNetEvent('mng-pizzadelivery:client:handleBlip', function(coords, status)
    if status == 'create' then
        currentBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(currentBlip, 434)
        SetBlipColour(currentBlip, 17)
        SetBlipScale(currentBlip, 0.7)
        SetBlipAsShortRange(currentBlip, true)
        SetBlipRoute(currentBlip, true)
        SetBlipRouteColour(currentBlip, 17)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Pizza Delivery Dropoff')
        EndTextCommandSetBlipName(currentBlip)
    else
        RemoveBlip(currentBlip)
    end
end)

RegisterNetEvent('mng-pizzadelivery:client:CreateDeliverZone', function(CurrentDelivery)
    local Coords = Config.DeliveryZones[CurrentDelivery]
    exports.interact:AddInteraction({
        coords = vec3(Coords.x, Coords.y, Coords.z),
        distance = 2.0,
        interactDst = 1.0,
        id = 'Pizza'..CurrentDelivery,
        options = {
             {
                label = 'Deliver Pizza',
                action = function()
                    DeliverPizza(CurrentDelivery)
                end,
                canInteract = function()
                    if HasBox then
                        return true
                    else
                        return false
                    end
                end,
            },
        }
    })
end)

RegisterNetEvent('mng-pizzadelivery:client:CreateSpecialZone', function(CurrentDelivery)
    local Coords = Config.SpecialDelivery[CurrentDelivery]
    exports.interact:AddInteraction({
        coords = vec3(Coords.x, Coords.y, Coords.z),
        distance = 2.0,
        interactDst = 1.0,
        id = 'Pizza'..CurrentDelivery,
        options = {
             {
                label = 'Deliver Pizza',
                action = function()
                    CheckDelivery()
                end,
                canInteract = function()
                    if HasBox then
                        return true
                    else
                        return false
                    end
                end,
            },
        }
    })
end)

RegisterNetEvent('mng-pizzadelivery:client:ChangeStatus', function(Action)
    if Action == 'Clear' then
        objects = {}
        DeliveryVehicle = nil
        HasBox = false
        AllFinished = false
        CurrentBlip = nil
        DeliveryZone = nil
        CurrentObject = nil
        IsWorking = false
    elseif Action == 'All' then
        AllFinished = true
    end
end)

RegisterNetEvent('mng-pizzadelivery:client:DestroyZone', function(Route)
    exports.interact:RemoveInteraction('Pizza'..Route)
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
    TriggerEvent('mng-pizzadelivery:client:handleBlip', 0, 'Clear')
    DeleteEntity(DeliveryVehicle)
    TriggerEvent('mng-pizzadelivery:client:handleProps', 0, DeliveryVehicle, 'clear')
    TriggerEvent('mng-pizzadelivery:client:ChangeStatus', 'Clear')
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DeleteEntity(Boss)
        TriggerEvent('mng-pizzadelivery:client:handleBlip', 0, 'Clear')
        DeleteEntity(DeliveryVehicle)
        TriggerEvent('mng-pizzadelivery:client:handleProps', 0, DeliveryVehicle, 'clear')
        TriggerEvent('mng-pizzadelivery:client:ChangeStatus', 'Clear')
    end
end)