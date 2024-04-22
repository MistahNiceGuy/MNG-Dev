local QBCore = exports['qb-core']:GetCoreObject()
local blips = {}
local Boss = nil
local Truck = nil
local Targets = {}


function CreatePeds()
    Boss = exports['rep-talkNPC']:CreateNPC({
        npc = 's_m_y_garbage',
        coords = vector4(Config.PedList[1].coords, Config.PedList[1].heading),
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
                                    TriggerServerEvent('mng-electrician:server:CanStart')
                                end
                            },
                            [2] = {
                                label = "Finish Work",
                                shouldClose = true,
                                action = function()
                                    TriggerServerEvent('mng-electrician:server:EndJob')
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

RegisterNetEvent('mng-electrician:client:CreateRepairZone', function(Route)
    local Coords = Config.Locations[Route].coords
    RepairZone = BoxZone:Create(vector3(Coords.x, Coords.y, Coords.z), 50.0, 50.0, {
        name="RepairZone",
        debugPoly = Config.Debug,
        minZ = Coords.z - 10,
        maxZ = Coords.z + 10,
    })

    RepairZone:onPlayerInOut(function(isPointInside)
        if isPointInside then
            TriggerServerEvent('mng-electrician:server:InZone')
        end
    end)
end)

RegisterNetEvent('mng-electrician:client:CreateTargets', function(Route)
    for i = 1, #Config.Locations[Route].repair do
        Targets[i] = {
            ID = nil,
            Busy = false,
        }
        local Coords = vector3(Config.Locations[Route].repair[i])
        Targets[i].ID = exports.interact:AddInteraction({
            coords = Coords,
            distance = 2.0,
            interactDst = 1.0,
            id = 'Repair'..i,
            options = {
                 {
                    label = 'Repair',
                    canInteract = function()
                        if not Targets[i].Busy then return true else return false end
                    end,
                    action = function()
                        DoRepair(i)
                    end,
                },
            }
        })
    end
    for i = 1, #Targets do
        Targets[i].Busy = false
    end
end)

function DoRepair(Num)
    TriggerServerEvent('mng-electrician:server:UpdateTarget', Num, true)
    if lib.progressCircle({
        duration = Config.RepairDuration * 1000,
        label = 'Repairing',
        position = 'bottom',
        useWhileDead = false,
        allowRagdoll = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = true,
        anim = {
            dict = 'amb@world_human_welding@male@base',
            clip = 'base',
            flag = 49,
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
        prop = {
            model = 'prop_weld_torch',
            bone = 28422,
            pos = vec3(0.0, 0.0, 0.0),
            rot = vec3(0.0, 0.0, 0.0),
        }
    })
    then
        exports.interact:RemoveInteraction('Repair'..Num)
        TriggerServerEvent('mng-electrician:server:UpdateWork', Num)
    else
        TriggerServerEvent('mng-electrician:server:UpdateTarget', Num, false)
    end
end

RegisterNetEvent('mng-electrician:client:ClearZone', function()
    RepairZone:destroy()
end)

RegisterNetEvent('mng-electrician:client:SetTruck', function(Veh)
    Truck = NetworkGetEntityFromNetworkId(Veh)
    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(Truck))
    exports['ps-fuel']:SetFuel(Truck, 100.0)
end)

RegisterNetEvent('mng-electrician:client:UpdateTarget', function(Num, Status)
    Targets[Num].Busy = Status
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
        DeleteEntity(Boss)
	end
end)