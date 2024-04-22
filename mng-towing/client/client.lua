local QBCore = exports['qb-core']:GetCoreObject()
local blips = {}
local Boss = nil
local Truck = nil
local TargetVeh = nil
local TowTarget = nil
local TowTruck = nil
local HasLoaded = false
local TowStatus = {
    ['IsWorking'] = false,
    ['TowLoaded'] = false,
    ['InDepotZone'] = false,
}

function CreatePeds()
    Boss = exports['rep-talkNPC']:CreateNPC({
        npc = 's_m_y_garbage',
        coords = Config.Ped.coords,
        name = 'Jerry Powers',
        tag = 'Towing Dispatcher',
        animScenario = 'WORLD_HUMAN_CLIPBOARD',
        position = "Impound Supervisor",
        color = "#00736F",
        startMSG = 'Hello, how can I assist you?'
    }, 
        {
            [1] = {
                label = "How does this job work?",
                shouldClose = false,
                action = function()
                    exports['rep-talkNPC']:updateMessage("Your group will be given a broken down vehicle to pick up. Tow it back to the depot and then impound it.")
                end
            },
            [2] = {
                label = "Start / Finish Work.",
                shouldClose = false,
                action = function()
                    exports['rep-talkNPC']:changeDialog( "You can finish your route early and still receive payment for each car you impounded.",
                        {
                            [1] = {
                                label = "Start Work.",
                                shouldClose = true,
                                action = function()
                                    TriggerServerEvent('mng-towing:server:CanStart')
                                end
                            },
                            [2] = {
                                label = "Finish Work",
                                shouldClose = true,
                                action = function()
                                    TriggerServerEvent('mng-towing:server:EndJob')
                                end
                            }
                        }
                    )
                end
            },
            [3] = {
                label = "Goodbye",
                shouldClose = true,
                action = function()
                    TriggerEvent('rep-talkNPC:client:close')
                end
            }
        })
        print(Boss)
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

RegisterNetEvent('mng-towing:client:SetTruck', function(Veh)
    Truck = NetworkGetEntityFromNetworkId(Veh)
    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(Truck))
    exports['ps-fuel']:SetFuel(Truck, 100.0)
    exports.interact:AddEntityInteraction({
        netId = Veh,
        id = math.random(1, 999),
        distance = 2.5,
        interactDst = 2.5,
        ignoreLos = true,
        offset = vec3(0.0, 0.0, 0.0), -- optional
        options = {
            {
                label = 'Unload Vehicle',
                action = function()
                    UnloadCar()
                end,
                canInteract = function()
                    if TowStatus['IsWorking'] and TowStatus['TowLoaded'] then
                        return true
                    end
                    return false
                end,
            },
        }
    })
end)

RegisterNetEvent('mng-towing:client:SetTargetVeh', function(Veh)
    TargetVeh = NetworkGetEntityFromNetworkId(Veh)
    SetVehicleDoorsLocked(TargetVeh, 3)
    SetVehicleEngineHealth(TargetVeh, 199)
    SetVehicleDoorOpen(TargetVeh, 4, false, false)
    SetEntityInvincible(TargetVeh, true)
    exports.interact:AddEntityInteraction({
        netId = Veh,
        id = math.random(1, 999),
        distance = 3.0,
        interactDst = 3.0,
        ignoreLos = true,
        offset = vec3(0.0, 0.0, 0.0), -- optional
        options = {
            {
                label = 'Load Vehicle',
                action = function()
                    TowCar()
                end,
                canInteract = function()
                    if TowStatus['IsWorking'] and not TowStatus['TowLoaded'] then
                        return true
                    end
                    return false
                end,
            },
            {
                label = 'Impound Vehicle',
                action = function()
                    ImpoundCar()
                end,
                canInteract = function()
                    if TowStatus['IsWorking'] and TowStatus['InDepotZone'] then
                        return true
                    end
                    return false
                end,
            },
        },
    })
end)

function TowCar()
    local src = source
    local Ped = PlayerPedId()
    local TargetCoords = GetEntityCoords(TargetVeh)
    local Min, Max = GetModelDimensions(GetEntityModel(Truck))
    local Ratio = math.abs(Min.y/Min.y)
    local Offset = Min.y - (Max.y + Max.y)*Ratio
    local Trunkpos = GetOffsetFromEntityInWorldCoords(Truck, 0, Offset, 0)
    local Dist = #(Trunkpos - TargetCoords)
    if Dist <= 12.0 then
        if lib.progressCircle({
            duration = 10000,
            label = 'Loading Vehicle',
            position = 'bottom',
            useWhileDead = false,
            allowRagdoll = false,
            allowCuffed = false,
            allowFalling = false,
            canCancel = true,
            anim = {
                dict = 'mini@repair',
                clip = 'fixing_a_ped',
                flag = 17,
                lockX = true,
                lockY = true,
                lockZ = true,
                disable = {
                    move = true,
                    car = true,
                    combat = true,
                    mouse = true,
                    sprint = true,
                },
            },
        })
        then
            ClearPedTasks(Ped)
                AttachEntityToEntity(TargetVeh, Truck, GetEntityBoneIndexByName(Truck, 'bodyshell'), 0.0, -1.5 + -0.85, 0.0 + 0.90, 0, 0, 0, 1, 1, 0, 1, 0, 1)
                Wait(500)
                FreezeEntityPosition(TargetVeh, true)
                TriggerServerEvent('mng-towing:server:SetGroupStatus', 'TowLoaded', true)
                TriggerServerEvent('mng-towing:server:SendHome', src)
        else
            ClearPedTasks(Ped)
                TriggerServerEvent('mng-towing:server:SetGroupStatus', 'TowLoaded', false)
        end
    else
        lib.notify({
            title = 'Too far away.',
            description = 'Your truck is not close enough to tow!',
            type = 'error'
        })
    end
end

RegisterNetEvent('mng-towing:client:MechTow', function()
    local Ped = PlayerPedId()
    TowTruck = GetPlayersLastVehicle()
    TowTarget = QBCore.Functions.GetClosestVehicle()
    local TargetCoords = GetEntityCoords(TowTarget)
    local Min, Max = GetModelDimensions(GetEntityModel(TowTruck))
    local Ratio = math.abs(Min.y/Min.y)
    local Offset = Min.y - (Max.y + Max.y)*Ratio
    local Trunkpos = GetOffsetFromEntityInWorldCoords(TowTruck, 0, Offset, 0)
    local Dist = #(Trunkpos - TargetCoords)
    if GetEntityModel(TowTruck) ~= 1353720154 or HasLoaded then
        return
    end
    if Dist <= 12.0 then
        if lib.progressCircle({
            duration = 10000,
            label = 'Loading Vehicle',
            position = 'bottom',
            useWhileDead = false,
            allowRagdoll = false,
            allowCuffed = false,
            allowFalling = false,
            canCancel = true,
            anim = {
                dict = 'mini@repair',
                clip = 'fixing_a_ped',
                flag = 17,
                lockX = true,
                lockY = true,
                lockZ = true,
                disable = {
                    move = true,
                    car = true,
                    combat = true,
                    mouse = true,
                    sprint = true,
                },
            },
        })
        then
            HasLoaded = true
            ClearPedTasks(Ped)
            AttachEntityToEntity(TowTarget, TowTruck, GetEntityBoneIndexByName(TowTruck, 'bodyshell'), 0.0, -1.5 + -0.85, 0.0 + 0.90, 0, 0, 0, 1, 1, 0, 1, 0, 1)
            Wait(500)
            FreezeEntityPosition(TowTarget, true)
        else
            ClearPedTasks(Ped)
        end
    else
        lib.notify({
            title = 'Too far away.',
            description = 'Your truck is not close enough to tow!',
            type = 'error'
        })
    end
end)

RegisterNetEvent('mng-towing:client:MechUnload', function()
    local Ped = PlayerPedId()
    if GetEntityModel(GetVehiclePedIsIn(Ped, false)) ~= 1353720154 then
        return
    end
    if HasLoaded then
        if lib.progressCircle({
            duration = 10000,
            label = 'Unloading Vehicle',
            position = 'bottom',
            useWhileDead = false,
            allowRagdoll = false,
            allowCuffed = false,
            allowFalling = false,
            canCancel = true,
            anim = {
                dict = 'mini@repair',
                clip = 'fixing_a_ped',
                flag = 17,
                lockX = true,
                lockY = true,
                lockZ = true,
                disable = {
                    move = true,
                    car = true,
                    combat = true,
                    mouse = true,
                    sprint = true,
                },
            },
        })
        then
            HasLoaded = false
            ClearPedTasks(Ped)
            DetachEntity(TowTarget, false, false)
            Wait(250)
            AttachEntityToEntity(TowTarget, TowTruck, 20, -0.0, -11.75, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
            DetachEntity(TowTarget, true, true)
            FreezeEntityPosition(TowTarget, false)
            SetEntityCoords(TowTarget, GetEntityCoords(TowTarget))
        else
            ClearPedTasks(Ped)
        end
    else
        lib.notify({
            title = 'Nothing to unload.',
            description = 'You don\'t have a vehicle loaded!',
            type = 'error'
        })
    end
end)

function UnloadCar()
    local Ped = PlayerPedId()
    if lib.progressCircle({
        duration = 10000,
        label = 'Unloading Vehicle',
        position = 'bottom',
        useWhileDead = false,
        allowRagdoll = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = true,
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 17,
            lockX = true,
            lockY = true,
            lockZ = true,
            disable = {
                move = true,
                car = true,
                combat = true,
                mouse = true,
                sprint = true,
            },
        },
    })
    then
        ClearPedTasks(Ped)
        DetachEntity(TargetVeh, false, false)
        TriggerServerEvent('mng-towing:server:SetGroupStatus', 'TowLoaded', false)
        Wait(250)
        AttachEntityToEntity(TargetVeh, Truck, 20, -0.0, -11.75, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
        DetachEntity(TargetVeh, true, true)
        FreezeEntityPosition(TargetVeh, false)
        SetEntityCoords(TargetVeh, GetEntityCoords(TargetVeh))
    else
        ClearPedTasks(Ped)
        TriggerServerEvent('mng-towing:server:SetGroupStatus', 'TowLoaded', true)
    end
end

function ImpoundCar()
    local src = source
    local Ped = PlayerPedId()
    if lib.progressCircle({
        duration = 10000,
        label = 'Impounding Vehicle',
        position = 'bottom',
        useWhileDead = false,
        allowRagdoll = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = true,
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 17,
            lockX = true,
            lockY = true,
            lockZ = true,
            disable = {
                move = true,
                car = true,
                combat = true,
                mouse = true,
                sprint = true,
            },
        },
    })
    then
        if TowStatus['InDepotZone'] then
            ClearPedTasks(Ped)
            DeleteEntity(TargetVeh)
            TriggerServerEvent('mng-towing:server:SetGroupStatus', 'TowLoaded', false)
            TargetVeh = nil
            TriggerServerEvent('mng-towing:server:UpdateJob')
        end
    else
        ClearPedTasks(Ped)
        TriggerServerEvent('mng-towing:server:SetGroupStatus', 'TowLoaded', true)
    end
end

RegisterNetEvent('mng-towing:client:SetStatus', function(Status, State)
    TowStatus[Status] = State
end)

RegisterNetEvent('mng-towing:client:CreateDepotZone', function()
    local Coords = Config.Depot
    TaxiZone = BoxZone:Create(vector3(Coords.x, Coords.y, Coords.z), 9.0, 16.0, {
        name="DepotZone",
        debugPoly = Config.Debug,
        heading = Coords.w,
        minZ = Coords.z - 1,
        maxZ = Coords.z + 1,
    })

    TaxiZone:onPlayerInOut(function(isPointInside)
        if isPointInside then
            TriggerServerEvent('mng-towing:server:SetGroupStatus', 'InDepotZone', true)
        else
            TriggerServerEvent('mng-towing:server:SetGroupStatus', 'InDepotZone', false)
        end
    end)
end)

RegisterNetEvent('mng-towing:client:ClearStatus', function()
    TowStatus = {
        ['IsWorking'] = false,
        ['TowLoaded'] = false,
        ['InDepotZone'] = false,
    }
    if DoesEntityExist(TargetVeh) then
        DeleteEntity(TargetVeh)
    end
    DepotZone:destroy()
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
        DeleteEntity(Boss)
	end
end)