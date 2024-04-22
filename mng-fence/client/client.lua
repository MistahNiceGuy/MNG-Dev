local QBCore = exports['qb-core']:GetCoreObject()
local SellListOptions = {}
local MissionListOptions = {}
local Boss = nil
local CurrentLocation = nil

function isPolice()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData then return end
    local job = PlayerData.job.name
    for i = 1, #Config.PoliceJobs do
        if job == Config.PoliceJobs[i] then
            return true
        end
    end

    return false
end

function CreatePeds()
    while CurrentLocation == nil do
        Wait(50)
    end
    Boss = exports['rep-talkNPC']:CreateNPC({
        npc = Config.Ped.Model,
        coords = Config.Ped.Coords[CurrentLocation],
        name = Config.Ped.Name,
        animScenario = Config.Ped.AnimScenario,
        tag = Config.Ped.Tag,
        color = "#00736F",
        startMSG = 'Hey, I\'m looking for certain items. Got what I need?'
    },
        {
            [1] = {
                label = "Yeah I might.",
                shouldClose = false,
                action = function()
                    TalkToNPC()
                end
            },
            [2] = {
                label = "Goodbye",
                shouldClose = true,
                action = function()
                    TriggerEvent('rep-talkNPC:client:close')
                end
            }
        })
    end

CreateThread(function()
    TriggerServerEvent('mng-fence:server:GetPedLocation')
    Wait(250)
    CreatePeds()
end)

RegisterNetEvent('mng-fence:client:UpdateLocation', function(Location)
    CurrentLocation = Location
end)

function TalkToNPC()
    if not isPolice() then
        exports['rep-talkNPC']:changeDialog('Take a look at what I\'m buying. There are also a few specialty items I need, hand those over and I\'ll be sure to take care of you.', {
        [1] = {
            label = "Sell Items.",
            shouldClose = false,
            action = function()
                SellList()
                TriggerEvent('rep-talkNPC:client:close')
            end
        },
        [2] = {
            label = "Give Items.",
            shouldClose = false,
            action = function()
                MissionList()
                TriggerEvent('rep-talkNPC:client:close')
            end
        },
        [3] = {
            label = "Goodbye",
            shouldClose = true,
            action = function()
                TriggerEvent('rep-talkNPC:client:close')
            end
        }})
    else
        TriggerServerEvent('mng-fence:server:NewLocation')
        exports['rep-talkNPC']:changeDialog('I can smell the pork, fuck off pig.', {
            [1] = {
                label = "Goodbye",
                shouldClose = true,
                action = function()
                    TriggerEvent('rep-talkNPC:client:close')
                end
            }})
    end
end

function SellList()
    SellListOptions = {}
    for k, v in pairs(Config.SellList) do
        SellListOptions[#SellListOptions+1] = {label = v.Label, args = {Item = k, Price = v.Price}}
    end
    if next(SellListOptions) == nil then return end
    SellListOptions[#SellListOptions + 1] = {label = 'Close'}
lib.registerMenu({
    id = 'Fence Sell',
    title = 'Sell Your Items',
    position = 'top-right',
    options = SellListOptions
}, function(selected, scrollIndex, args)
    if selected == #SellListOptions then return end
    lib.callback('mng-fence:server:GetItems', false, function(Amount)
        if Amount ~= 0 then
            local Total = (Amount * Config.SellList[args.Item].Price)
            local Alert = lib.alertDialog({
                header = 'Are you sure?',
                content = 'You are about to sell '..Amount..' '..Config.SellList[args.Item].Label..' for $'..Total,
                centered = true,
                cancel = true
            })
            if Alert == 'confirm' then
                TriggerServerEvent('mng-fence:server:SellItems', args.Item, Amount, Total)
            end
        else
            lib.notify({
                title = 'You don\'t have any '..Config.SellList[args.Item].Label,
                type = 'error'
            })
            return
        end
    end, args.Item)
end)
    lib.showMenu('Fence Sell')
end

function MissionList()
    local Player = QBCore.Functions.GetPlayerData()
    local Rep = Player.metadata["fencerep"]
    MissionListOptions = {}
    for k, v in pairs(Config.SellList) do
        if Rep >= v.Rep then
            MissionListOptions[#MissionListOptions+1] = {label = v.Label, args = {Item = k, Price = v.Price}}
        end
    end
    if next(MissionListOptions) == nil then return end
    MissionListOptions[#MissionListOptions + 1] = {label = 'Close'}
    lib.registerMenu({
        id = 'Fence Mission',
        title = 'Handover Items',
        position = 'top-right',
        options = MissionListOptions
    }, function(selected, scrollIndex, args)
        if selected == #MissionListOptions then return end
        lib.callback('mng-fence:server:GetItems', false, function(Amount)
            if Amount ~= 0 then
                local Alert = lib.alertDialog({
                    header = 'Are you sure?',
                    content = 'You are about to handover '..Amount..' '..Config.MissionList[args.Item].Label,
                    centered = true,
                    cancel = true
                })
                if Alert == 'confirm' then
                    TriggerServerEvent('mng-fence:server:GiveItems', args.Item, Amount)
                end
            else
                lib.notify({
                    title = 'You don\'t have any '..Config.MissionList[args.Item].Label,
                    type = 'error'
                })
                return
            end
        end, args.Item)
    end)
    lib.showMenu('Fence Mission')
end

RegisterNetEvent('mng-fence:client:HandlePed', function()
    FreezeEntityPosition(Boss, false)
    SetPedKeepTask(Boss, false)
    TaskSetBlockingOfNonTemporaryEvents(Boss, false)
    TaskWanderStandard(Boss, 10.0, 10)
    SetPedAsNoLongerNeeded(Boss)
    Wait(10000)
    DeletePed(Boss)
    CreatePeds()
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
        DeleteEntity(Boss)
	end
end)