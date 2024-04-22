local QBCore = exports['qb-core']:GetCoreObject()
local fishing = false
local fishrod = nil
local peds = {}
local jobPeds = {}
local Boss = {}

exports('castrod', function(data, slot)
    local hasItem = nil
    local ped = PlayerPedId()
    local BaitType = nil
    if AreaCheck() ~= nil then
        if AreaCheck() == 'freshwater' then
            BaitType = Config.FreshWaterBait
            hasItem = exports.ox_inventory:GetItemCount(Config.FreshWaterBait)
            if hasItem <= 0 then
                hasItem = exports.ox_inventory:GetItemCount(Config.Lure)
                BaitType = Config.Lure
            end
        elseif AreaCheck() == 'saltwater' then 
            BaitType = Config.SaltWaterBait
            hasItem = exports.ox_inventory:GetItemCount(Config.SaltWaterBait)
            if hasItem <= 0 then
                hasItem = exports.ox_inventory:GetItemCount(Config.Lure)
                BaitType = Config.Lure
            end
        end
        if hasItem > 0 then
            if not fishing then
                CastingAnim()
                fishing = true
                if Config.Debug then
                    print(BaitType)
                end
                Startfishing(BaitType)
            else
                lib.notify({
                    title = 'Can\'t do that.',
                    description = 'You are already fishing!',
                    type = 'error'
                })
            end
        else
            lib.notify({
                title = 'Wrong bait.',
                description = 'You don\'t have the correct type of bait!',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Wrong area.',
            description = 'You can\'t fish here!',
            type = 'error'
        })
    end
end)


function Startfishing(TypeOfBait)
    local src = source
    local Player = QBCore.Functions.GetPlayerData()
    local Skill1 = Player.metadata["fishingskill1"]
    local cid = Player.citizenid

    -- QBCore.Functions.TriggerCallback('mng-metadata:server:GetMetaData', function(MetaData)
    local CastTime = math.random(Config.MinBiteTime, Config.MaxBiteTime) * 1000
    CastTime = CastTime - ((Skill1 * Config.SkillTimeReduction) * 1000)
    if CastTime < 4000 then
        CastTime = 4000
    end
if fishrod == nil then
    LoadPropDict('prop_fishing_rod_01')
    fishrod = AttachEntityToPed('prop_fishing_rod_01',60309, 0,0,0, 0,0,0)
end
LocalPlayer.state.invBusy = true
while CastTime > Config.BiteNotifyTime do
    if IsControlPressed(0, Config.CancelKey) then
        ClearState()
        return
    end
    Wait(50)
    CastTime = CastTime - 100
end
lib.notify({
    title = 'Fish Biting.',
    description = 'You start to feel a nibble!',
    type = 'success'
})
Wait(Config.BiteNotifyTime * 1000)
QBCore.Functions.TriggerCallback('mng-fishing:UseBait', function(bait)
    if bait then
        exports['boii_minigames']:skill_bar({
            style = 'default', -- Style template
            icon = 'fa-solid fa-fish', -- Any font-awesome icon; will use template icon if none is provided
            orientation = 2, -- Orientation of the bar; 1 = horizontal centre, 2 = vertical right.
            area_size = 20, -- Size of the target area in %
            perfect_area_size = 5, -- Size of the perfect area in %
            speed = 0.5, -- Speed the target area moves
            moving_icon = true, -- Toggle icon movement; true = icon will move randomly, false = icon will stay in a static position
            icon_speed = 3, -- Speed to move the icon if icon movement enabled; this value is / 100 in the javascript side true value is 0.03
        }, function(success)
            if success ~= 'failed' then
                QBCore.Functions.TriggerCallback('mng-fishing:CatchFish', function(caught)
                    if caught then
                        lib.notify({
                            title = 'Fish Caught.',
                            type = 'success'
                        })
                        ClearState()
                    else
                        lib.notify({
                            title = 'Need room.',
                            description = 'You didn\'t have space and tossed the fish back.',
                            type = 'error'
                        })
                        ClearState()
                    end
                end, AreaCheck(), GetClockHours(), GetRainLevel(), TypeOfBait, success)
            else
                lib.notify({
                    title = 'Failed.',
                    description = 'Fish got away!',
                    type = 'error'
                })
                ClearState()
            end
        end)
    else
        lib.notify({
            title = 'No bait.',
            description = 'You don\'t have bait!',
            type = 'error'
        })
        ClearState()
    end
end, TypeOfBait)
end

RegisterNetEvent('mng-fishing:client:StatMenu', function()
    local Player = QBCore.Functions.GetPlayerData()
    local Level = Player.metadata["fishinglevel"]
    local Experience = Player.metadata["fishingexperience"]
    local Skill1 = Player.metadata["fishingskill1"]
    local Skill2 = Player.metadata["fishingskill2"]
    local SkillPoints = Player.metadata["fishingskillpoints"]
        local statmenu = {
            {
                header = "Fishing Level "..Level,
                txt = 'Experience '..Experience..' / '..Config.ExpPerLevel,
                isMenuHeader = true
            }
        }
        statmenu[#statmenu+1] = {
            header = 'You Have '..SkillPoints..' Skillpoint(s) To Spend',
            txt = 'Click a Skill to Spend a Skillpoint and Level it Up',
            isMenuHeader = true
        }
        statmenu[#statmenu+1] = {
            header = 'Angler',
            txt = "Angler Level "..Skill1,
            params = {
                event = "mng-fishing:client:StatConfirm",
                args = {
                    stat = 'one',
                }
            }
        }
        statmenu[#statmenu+1] = {
            header = 'Luck',
            txt = "Luck Level "..Skill2,
            params = {
                event = "mng-fishing:client:StatConfirm",
                args = {
                    stat = 'two',
                }
            }
        }
        statmenu[#statmenu+1] = {
            header = 'Close Menu',
        txt = '',
        params = {
            event = "qb-menu:closeMenu",
        }
    }
    exports['qb-menu']:openMenu(statmenu)
end)

RegisterNetEvent("mng-fishing:client:StatConfirm", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayerData()
    local Level = Player.metadata["fishinglevel"]
    local Experience = Player.metadata["fishingexperience"]
    local Skill1 = Player.metadata["fishingskill1"]
    local Skill2 = Player.metadata["fishingskill2"]
    local SkillPoints = Player.metadata["fishingskillpoints"]
    local cid = Player.citizenid
    -- QBCore.Functions.TriggerCallback('mng-metadata:server:GetMetaData', function(MetaData)
        if SkillPoints > 0 then
            local skillonemenu = {
                {
                    header = "Are You Sure?",
                    isMenuHeader = true
                }
            }
            skillonemenu[#skillonemenu+1] = {
                header = 'Yes',
                txt = 'Spend 1 Skillpoint to Increase Angler to Level '..(Skill1 + 1),
                params = {
                    isServer = true,
                    event = 'mng:server:SpendSkill',
                    args = {
                        skill = 'fishingskill1',
                    }
                }
            }
            skillonemenu[#skillonemenu+1] = {
                header = 'No',
                txt = '',
                params = {
                    event = "mng-fishing:client:StatMenu",
                }
            }
            local skilltwomenu = {
                {
                    header = "Are You Sure?",
                    isMenuHeader = true
                }
            }
            skilltwomenu[#skilltwomenu+1] = {
                header = 'Yes',
                txt = 'Spend 1 Skillpoint to Increase Luck to Level '..(Skill2 + 1),
                params = {
                    isServer = true,
                    event = 'mng:server:SpendSkill',
                    args = {
                        skill = 'fishingskill2',
                    }
                }
            }
            skilltwomenu[#skilltwomenu+1] = {
                header = 'No',
                txt = '',
                params = {
                    event = "mng-fishing:client:StatMenu",
                }
            }
            if data.stat == 'one' then
                exports['qb-menu']:openMenu(skillonemenu)
            else
                exports['qb-menu']:openMenu(skilltwomenu)
            end
        else
            lib.notify({
                title = 'No skillpoints.',
                description = 'You don\'t have any skillpoints to spend!',
                type = 'error'
            })
        end
-- end, cid)
end)

RegisterNetEvent('mng-fishing:client:FishMenu', function()
    local src = source
    local Player = QBCore.Functions.GetPlayerData()
    local Level = Player.metadata["fishinglevel"]
    local Experience = Player.metadata["fishingexperience"]
    local Skill1 = Player.metadata["fishingskill1"]
    local Skill2 = Player.metadata["fishingskill2"]
    local SkillPoints = Player.metadata["fishingskillpoints"]
    local cid = Player.citizenid
    -- QBCore.Functions.TriggerCallback('mng-metadata:server:GetMetaData', function(MetaData)
        local fishmenu = {
            {
                header = "Fishing Level "..Level,
                txt = 'Experience '..Experience..' / '..Config.ExpPerLevel,
                isMenuHeader = true
            }
        }
        fishmenu[#fishmenu+1] = {
            header = 'Skill Menu',
            txt = "Open Fishing Skill Menu",
            params = {
                event = "mng-fishing:client:StatMenu",
            }
        }
        fishmenu[#fishmenu+1] = {
            header = 'Shop',
            txt = "Open Fishing Shop",
            params = {
                event = "mng-fishing:client:FishingShop",
                args = {
                    level = Level,
                }
            }
        }
        fishmenu[#fishmenu+1] = {
            header = 'Sell Fish',
            txt = "Sell All Of Your Fish",
            params = {
                isServer = true,
                event = "mng-fishing:server:SellAllFish",
            }
        }
        fishmenu[#fishmenu+1] = {
            header = 'Close Menu',
        txt = '',
        params = {
            event = "qb-menu:closeMenu",
        }
        }
        exports['qb-menu']:openMenu(fishmenu)
-- end, cid)
end)

RegisterNetEvent('mng-fishing:client:FishingShop', function()
    local src = source
    local Player = QBCore.Functions.GetPlayerData()
    local Level = Player.metadata["fishinglevel"]
    local NotMaxLevel = true
    local LureTxt = "Available at level "..Config.MaxLevel
    if tonumber(Level) >= Config.LureLevel then
        NotMaxLevel = false
        LureTxt = '$'..Config.ShopPrices['lure']
    end
    local shopmenu = {
        {
            header = "Fishing Shop",
            isMenuHeader = true
        }
    }
    shopmenu[#shopmenu+1] = {
        header = 'Fishing Rod',
        txt = '$'..Config.ShopPrices['fishingrod'],
        params = {
            event = "mng-fishing:client:BuyItem",
            args = {
                item = Config.FishingRod,
                name = 'Fishing Rod',
            }
        }
    }
    shopmenu[#shopmenu+1] = {
        header = 'Freshwater Bait',
        txt = '$'..Config.ShopPrices['freshbait'],
        params = {
            event = "mng-fishing:client:BuyItem",
            args = {
                item = Config.FreshWaterBait,
                name = 'Freshwater Bait',
            }
        }
    }
    shopmenu[#shopmenu+1] = {
        header = 'Saltwater Bait',
        txt = '$'..Config.ShopPrices['saltbait'],
        params = {
            event = "mng-fishing:client:BuyItem",
            args = {
                item = Config.SaltWaterBait,
                name = 'Saltwater Bait',
            }
        }
    }
    shopmenu[#shopmenu+1] = {
        header = 'Fishing Lure',
        txt = LureTxt,
        disabled = NotMaxLevel,
        params = {
            event = "mng-fishing:client:BuyItem",
            args = {
                item = Config.Lure,
                name = 'Fishing Lure',
            }
        }
    }
    shopmenu[#shopmenu+1] = {
        header = 'Close Menu',
    txt = '',
    params = {
        event = "qb-menu:closeMenu",
    }
}
exports['qb-menu']:openMenu(shopmenu)
end)

RegisterNetEvent('mng-fishing:client:BuyItem', function(data)
    local purchase = exports['qb-input']:ShowInput({
        header = 'Purchase '..data.name,
        submitText = 'Submit',
        inputs = {
            {
                text = 'Amount',
                name = 'amount',
                type = 'number',
                isRequired = true,
            },
            {
                text = 'Payment Type',
                name = 'paymenttype',
                type = 'radio',
                options = {
                    {value = 'cash', text = 'Cash'},
                    {value = 'bank', text = 'Bank'},
                },
            },
        },
    })
    if purchase ~= nil then
        if tonumber(purchase.amount) >= 1 then
            QBCore.Functions.TriggerCallback('mng:server:BuyItem', function(CanBuy)
                if CanBuy == 'success' then 
                    lib.notify({
                        title = 'Purchased.',
                        description = 'You have purchased '..purchase.amount..' '..data.name,
                        type = 'success'
                    })
                elseif CanBuy == 'weight' then
                        lib.notify({
                            title = 'No room.',
                            description = 'You do not have enough room for '..purchase.amount..' '..data.name,
                            type = 'error'
                        })
                elseif CanBuy == 'money' then
                        lib.notify({
                            title = 'No money.',
                            description = 'You do not have money for '..purchase.amount..' '..data.name,
                            type = 'error'
                        })
                end
            end, purchase, tostring(data.item))
        else
            lib.notify({
                title = 'Error.',
                description = 'You can\'t purchase a negative amount!',
                type = 'error'
            })
        end
    end
end)

function ClearState()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    DeleteObject(fishrod)
    DeleteEntity(fishrod)
    fishrod = nil
    fishing = false
    LocalPlayer.state.invBusy = false
end
--Some code i found in vrP_fishing https://github.com/OriginalGamers/vrp_fishing_animations/blob/master/vrp_fishing_animations/client.lua
function AttachEntityToPed(prop,bone_ID,x,y,z,RotX,RotY,RotZ)
	BoneID = GetPedBoneIndex(PlayerPedId(), bone_ID)
	obj = CreateObject(GetHashKey(prop),  1729.73,  6403.90,  34.56,  true,  true,  true)
	vX,vY,vZ = table.unpack(GetEntityCoords(PlayerPedId()))
	xRot, yRot, zRot = table.unpack(GetEntityRotation(PlayerPedId(),2))
	AttachEntityToEntity(obj,  PlayerPedId(),  BoneID, x,y,z, RotX,RotY,RotZ,  false, false, false, false, 2, true)
	return obj
end
-- End of the VRP code
--Anims thanks to JayCC https://github.com/Jaycc-Was-Taken
function FishingAnim()
    local ped = PlayerPedId()
    LoadAnim("amb@world_human_stand_fishing@idle_a")
    TaskPlayAnim(ped, "amb@world_human_stand_fishing@idle_a", "idle_c", 20.0, -8, -1, 17, 0, 0, 0, 0)
end

function CastingAnim()
    local ped = PlayerPedId()
    LoadAnim("mini@tennis")
    TaskPlayAnim(ped, "mini@tennis", "close_fh_ts_md", 1.0, 1.0, 250, 48, 0, 0, 0, 0)
    Wait(400)
    FishingAnim()
end
function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
	  RequestAnimDict(dict)
	  Wait(10)
	end
end
function LoadPropDict(model)
	while not HasModelLoaded(GetHashKey(model)) do
	  RequestModel(GetHashKey(model))
	  Wait(10)
	end
end
function LoadAnimSet(set)
    while not HasAnimSetLoaded(set) do
        RequestAnimSet(set)
        Wait(10)
    end
end
-- End of JayCC code

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
    for i = 1, #Config.PedList do
        Boss[i] = exports['rep-talkNPC']:CreateNPC({
        npc = Config.PedList[i].model,
        coords = vector4(Config.PedList[i].coords, Config.PedList[i].heading),
        name = Config.PedList[i].name,
        tag = Config.PedList[i].tag,
        animScenario = Config.PedList[i].scenario,
        position = Config.PedList[i].position,
        color = "#00736F",
        startMSG = 'Hello, how can I assist you?'
    }, 
        {
            [1] = {
                label = "How do I fish?",
                shouldClose = false,
                action = function()
                    exports['rep-talkNPC']:updateMessage("Buy a fishing rod and bait and cast into any body of water you can find.")
                end
            },
            [2] = {
                label = "View Stat Menu",
                shouldClose = true,
                action = function()
                    TriggerEvent('mng-fishing:client:StatMenu')
                end
            },
            [3] = {
                label = "Open Shop",
                shouldClose = true,
                action = function()
                    TriggerEvent('mng-fishing:client:FishingShop')
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
end
local blips = {}
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

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for i = 1, #Boss do
            DeleteEntity(Boss[i])
        end
        ClearState()
    end
end)
