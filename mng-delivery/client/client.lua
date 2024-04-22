local QBCore = exports['qb-core']:GetCoreObject()
local jobPeds = {}
local blips = {}
local HasBox = false
local PickupCheck = false
local BoxObject = nil
local Truck = nil
local DeliverZone = nil
local Boss = nil

local nearPed = function(model, coords, heading, gender, animDict, animName, scenario)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(1)
	end
	if gender == 'male' then
		genderNum = 4
	elseif gender == 'female' then 
		genderNum = 5
	else
		print("No gender provided! Check your configuration!")
	end
	if Config.MinusOne then 
		local x, y, z = table.unpack(coords)
		ped = CreatePed(genderNum, GetHashKey(model), x, y, z - 1, heading, false, true)
		table.insert(jobPeds, ped)
	else
		ped = CreatePed(genderNum, GetHashKey(v.model), coords, heading, false, true)
		table.insert(jobPeds, ped)
	end
	SetEntityAlpha(ped, 0, false)
	if Config.Frozen then
		FreezeEntityPosition(ped, true)
	end
	if Config.Invincible then
		SetEntityInvincible(ped, true)
	end
	if Config.Stoic then
		SetBlockingOfNonTemporaryEvents(ped, true)
	end
	if animDict and animName then
		RequestAnimDict(animDict)
		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(1)
		end
		TaskPlayAnim(ped, animDict, animName, 8.0, 0, -1, 1, 0, 0, 0)
	end
	if scenario then
		TaskStartScenarioInPlace(ped, scenario, 0, true)
	end
	if Config.Fade then
		for i = 0, 255, 51 do
			Citizen.Wait(50)
			SetEntityAlpha(ped, i, false)
		end
	end
	return ped
end
function CreatePeds()
    Boss = exports['rep-talkNPC']:CreateNPC({
        npc = Config.PedList[1].model,
        coords = vector4(Config.PedList[1].coords, Config.PedList[1].heading),
        name = 'Brock Lovitt',
        tag = 'Post Op Supervisor',
        animScenario = 'WORLD_HUMAN_CLIPBOARD',
        position = "Post Op Supervisor",
        color = "#00736F",
        startMSG = 'Hello, how can I assist you?'
    }, 
        {
            [1] = {
                label = "How does this job work?",
                shouldClose = false,
                action = function()
                    exports['rep-talkNPC']:updateMessage("Your group will be given a delivery location. When you arrive at your location, third eye the back of the truck to grab a box, then head to the deliver point and deliver it.")
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
                                    TriggerServerEvent('mng-delivery:server:CanStart')
                                end
                            },
                            [2] = {
                                label = "Finish Work",
                                shouldClose = true,
                                action = function()
                                    TriggerServerEvent('mng-delivery:server:EndJob')
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

RegisterNetEvent('mng-delivery:client:ClearZone', function(Route)
    exports.interact:RemoveInteraction('Deliver'..Route)
end)

RegisterNetEvent('mng-delivery:client:CreateTruckTarget', function(Veh)
    Truck = NetworkGetEntityFromNetworkId(Veh)
    exports.interact:AddEntityInteraction({
        netId = Veh,
        name = 'Grab Package', -- optional
        id = 'Grab Package', -- needed for removing interactions
        distance = 2.0, -- optional
        interactDst = 1.5,
        offset = vec3(0.0, -3.6, 0.45),
        options = {
            {
                label = 'Grab Package',
                canInteract = function()
                    if HasBox then
                        return false
                    end
                    return true
                end,
                action = function()
                    GrabBox()
                end,
            },
            {
                label = 'Load Package',
                canInteract = function()
                    if HasBox then
                        return true
                    end
                    return false
                end,
                action = function()
                    LoadBox()
                end,
            },
        }
    })
end)

RegisterNetEvent('mng-delivery:client:ClearStatus', function()
    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    HasBox = false
    DetachEntity(BoxObject, 1, false)
    DeleteObject(BoxObject)
end)

RegisterNetEvent('mng-delivery:client:SetTruck', function()
    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(Truck))
	exports['ps-fuel']:SetFuel(Truck, 100.0)
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

function TakeBoxAnim()
    local ped = PlayerPedId()
    LoadAnimation('anim@heists@box_carry@')
    TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
    BoxObject = CreateObject(`bzzz_prop_custom_box_2a`, 0, 0, 0, true, true, true)
    AttachEntityToEntity(BoxObject, ped, GetPedBoneIndex(ped, 60309), 0.025, 0.08, 0.255, 100.0, 20.0, 32.0, true, true, false, true, 1, true)
    AnimBoxCheck()
end

function GrabBox()
    if lib.progressCircle({
        duration = 3000,
        label = 'Grabbing Box',
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
        HasBox = true
        ClearPedTasks(cache.ped)
        TakeBoxAnim()
    else
        ClearPedTasks(cache.ped)
        HasBox = false
    end
end

function LoadBox()
    if lib.progressCircle({
        duration = 3000,
        label = 'Loading Box',
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
        TriggerEvent('mng-delivery:client:ClearStatus')
    else
        ClearPedTasks(cache.ped)
        HasBox = true
    end
end

function DeliverBox()
    if lib.progressCircle({
        duration = 3000,
        label = 'Delivering Box',
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
        TriggerServerEvent('mng-delivery:server:UpdateBoxes')
        TriggerEvent('mng-delivery:client:ClearStatus')
    else
        HasBox = true
    end
end

function DeliverZoneCheck()
    PickupCheck = true
    CreateThread(function()
        while PickupCheck do
            if IsControlJustPressed(0, 38) then
                DeliverBox()
                exports['qb-core']:KeyPressed(38)
                PickupCheck = false
            end
            Wait(1)
        end
    end)
end

RegisterNetEvent('mng-delivery:client:CreateDeliverZone', function(Route)
    exports.interact:AddInteraction({
        coords = Config.Locations[Route].coords,
        distance = 2.0,
        interactDst = 1.0,
        id = 'Deliver'..Route,
        options = {
             {
                label = 'Deliver Package!',
                canInteract = function()
                    if HasBox then
                        return true
                    end
                    return false
                end,
                action = function(entity, coords, args)
                    DeliverBox()
                end,
            },
        }
    })
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
        TriggerEvent('mng-delivery:client:ClearStatus')
        DeleteEntity(Boss)
	end
end)