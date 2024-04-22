local QBCore = exports['qb-core']:GetCoreObject()
local Jobs = {}
local Stages = {
    [1] = {name="Head to the Dumpster.", isDone = false, id=1},
    [2] = {name="Collect Bags of Trash.", isDone = false, id=2},
    [3] = {name="Return to the Depot and Get Paid.", isDone = false, id=3},
}

function UpdateGroupStage(Group, Index)
    Jobs[Group].Stages[Index].isDone = true
    exports['qb-phone']:setJobStatus(Group, 'Garbage', Jobs[Group].Stages)
end

function CreateJobGroup(src)
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    if Group then
        local leader = exports['qb-phone']:GetGroupLeader(Group)
        if src == leader then
            if exports['qb-phone']:getJobStatus(Group) == 'WAITING' then
                Jobs[Group] = {
                    Stages = lib.table.deepclone(Stages),
                    Truck = nil,
                    CurrentBags = 0,
                    CurrentMaxBags = 0,
                    CurrentStops = 0,
                    Stops = 0,
                    CurrentRoute = 0,
                    JobFinished = false,
                }
              exports['qb-phone']:setJobStatus(Group, 'Garbage', Jobs[Group].Stages)
            end
        end
      end
end

RegisterServerEvent('mng-garbage:server:CanStart', function()
    local src = source
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Size = nil
    if Jobs[Group] ~= nil then
        TriggerClientEvent('QBCore:Notify', src, 'You are already working a route!', 'error')
        return
    end
    if Group == nil then
        TriggerClientEvent('QBCore:Notify', src, 'You need to be in a group to start this job!', 'error')
    else
        local Leader = exports['qb-phone']:GetGroupLeader(Group)
        Size = exports['qb-phone']:getGroupSize(Group)
        if Size > Config.MaxGroupSize then
            TriggerClientEvent('QBCore:Notify', src, 'You can only have '..Config.MaxGroupSize..' people working this job!', 'error')
            return
        else
            if src == Leader then
                if exports['qb-phone']:getJobStatus(Group) ~= 'WAITING' then
                    TriggerClientEvent('QBCore:Notify', src, 'Your group is already working another job!', 'error')
                    return
                else
                    CreateJobGroup(src)
                    Wait(100)
                    StartJob(src)
                end
            else
                TriggerClientEvent('QBCore:Notify', src, 'Only the leader of the group can start this job!', 'error')
            end
        end
    end
end)

function StartJob(src)
    local Veh = CreateVehicle(Config.Truck.Model, Config.Truck.Spawn.x, Config.Truck.Spawn.y, Config.Truck.Spawn.z, Config.Truck.Spawn.w, true, true)
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Size = exports['qb-phone']:getGroupSize(Group)
    local TotalStops = math.random((Config.MinStops + Size), (Config.MaxStops + Size))
    local Members = exports['qb-phone']:getGroupMembers(Group)
    local vehID = nil
    while not DoesEntityExist(Veh) do
        Wait(25)
    end
    if DoesEntityExist(Veh) then
        local plate = "TRASH"..tostring(math.random(100, 999))
        SetVehicleNumberPlateText(Veh, plate)
        SetVehicleDoorsLocked(Veh, 1)
        SetEntityDistanceCullingRadius(Veh, 999999999.0)
        Wait(500)
        vehID = NetworkGetNetworkIdFromEntity(Veh)
    end
    Jobs[Group].Truck = Veh
    Jobs[Group].Stops = TotalStops
    Wait(250)
    for i = 1, #Members do
    TriggerClientEvent('mng-garbage:client:SetTruck', Members[i], vehID)
    end
    NextStop(src)
end


function NextStop(src)
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Size = exports['qb-phone']:getGroupSize(Group)
    local vehID = NetworkGetNetworkIdFromEntity(Jobs[Group].Truck)
    local NextRoute = PickRandomRoute(src)
    local RouteBags = math.random((Config.MinBags + Size), (Config.MaxBags + Size))
    local Members = exports['qb-phone']:getGroupMembers(Group)
    Jobs[Group].CurrentRoute = NextRoute
    Jobs[Group].CurrentMaxBags = RouteBags
    local blip = {
        coords = Config.Locations[Jobs[Group].CurrentRoute].coords,
        color = 5,
        alpha = 255,
        sprite = 318,
        scale = 0.5,
        label = "Garbage Route",
        route = true,
        routeColor = 5,
    }

    local message = "Head to the dumpster!"
    exports['qb-phone']:pNotifyGroup(Group, "Garbage Job", message, "fas fa-recycle", '#008FFF', 7500)
    exports['qb-phone']:CreateBlipForGroup(Group, "Garbage", blip)
    for i = 1, #Members do
    TriggerClientEvent('mng-garbage:client:CreateTrashZone', Members[i], Jobs[Group].CurrentRoute)
    TriggerClientEvent('mng-garbage:client:CreateTruckZone', Members[i], vehID)
    end
end

function PickRandomRoute(src)
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local NewRoute = math.random(1, #Config.Locations)
    while NewRoute == Jobs[Group].CurrentRoute do
        NewRoute = math.random(1, #Config.Locations)
        Wait(250)
    end
    return NewRoute
end

RegisterServerEvent('mng-gargbage:server:InZone', function()
    local src = source
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    if not Jobs[Group].Stages[1].isDone then
        UpdateGroupStage(Group, 1)
    end
end)

RegisterServerEvent('mng-garbage:server:UpdateBags', function()
    local src = source
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Members = exports['qb-phone']:getGroupMembers(Group)
    Jobs[Group].CurrentBags = Jobs[Group].CurrentBags + 1
    local message = "Trash Bags: "..Jobs[Group].CurrentBags..' / '..Jobs[Group].CurrentMaxBags
    exports['qb-phone']:pNotifyGroup(Group, "Garbage Job", message, "fas fa-recycle", '#008FFF', 7500)
    if Jobs[Group].CurrentBags >= Jobs[Group].CurrentMaxBags then
        Jobs[Group].CurrentStops = Jobs[Group].CurrentStops + 1
        exports['qb-phone']:RemoveBlipForGroup(Group, "Garbage")
        for i = 1, #Members do
        TriggerClientEvent('mng-garbage:client:ClearStatus', Members[i])
        TriggerClientEvent('mng-garbage:client:ClearZone', Members[i], Jobs[Group].CurrentRoute)
    end
    Jobs[Group].CurrentBags = 0
    if Jobs[Group].CurrentStops >= Jobs[Group].Stops then
        SendHome(src)
        UpdateGroupStage(Group, 2)
    else
        NextStop(src)
        Jobs[Group].Stages = lib.table.deepclone(Stages)
        exports['qb-phone']:setJobStatus(Group, 'Garbage', Jobs[Group].Stages)
        end
    end
end)

function SendHome(src)
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Members = exports['qb-phone']:getGroupMembers(Group)
    Jobs[Group].Finished = true
    local blip = {
        coords = Config.PedList[1].coords,
        color = 5,
        alpha = 255,
        sprite = 318,
        scale = 0.5,
        label = "Return to Garbage Depot",
        route = true,
        routeColor = 5,
    }

    local message = "Head Back to the Depot to get paid!"
    exports['qb-phone']:pNotifyGroup(Group, "Garbage Job", message, "fas fa-recycle", '#008FFF', 7500)
    exports['qb-phone']:CreateBlipForGroup(Group, "GarbageHome", blip)
end

RegisterServerEvent('mng-garbage:server:EndJob', function()
    local src = source
    local Player = nil
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    if Group == nil or Jobs[Group] == nil then TriggerClientEvent('QBCore:Notify', src, 'You are not working right now!' ,"error") return end
    local Members = exports['qb-phone']:getGroupMembers(Group)
    local Leader = exports['qb-phone']:GetGroupLeader(Group)
    local PayoutCash = 0
    local PayoutItem = 0
    local TruckCoords = GetEntityCoords(Jobs[Group].Truck)
    local TruckDist = #(TruckCoords - Config.PedList[1].coords)
    local PlayerDist = true
    for i = 1, #Members do
        if #(GetEntityCoords(GetPlayerPed(Members[i])) - Config.PedList[1].coords) > 25 then
            PlayerDist = false
        end
    end
    if Leader == src then
        if TruckDist <= 25 then
            if PlayerDist then
                for i = 1, Jobs[Group].CurrentStops do
                    PayoutCash = PayoutCash + math.random(Config.PayMin, Config.PayMax)
                    PayoutItem = PayoutItem + Config.Payout
                end
                for i = 1, #Members do
                    Player = QBCore.Functions.GetPlayer(Members[i])
                    if exports.ox_inventory:CanCarryItem(Members[i], Config.PayoutItem, PayoutItem) and PayoutItem ~= 0 then
                        Player.Functions.AddItem(Config.PayoutItem, PayoutItem)
                        TriggerClientEvent('inventory:client:ItemBox', Members[i], QBCore.Shared.Items[Config.PayoutItem], "add", PayoutItem)
                    end
                    Player.Functions.AddMoney("cash", PayoutCash, 'Garbage Run Payout')
                end
                DeleteEntity(Jobs[Group].Truck)
                exports['qb-phone']:RemoveBlipForGroup(Group, "Garbage")
                exports['qb-phone']:RemoveBlipForGroup(Group, "GarbageHome")
                exports["qb-phone"]:resetJobStatus(Group)
                Jobs[Group] = nil
            else
                TriggerClientEvent('QBCore:Notify', src, 'You must have all group members present!' ,"error")
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'You must bring the trash truck back!' ,"error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'The Leader must end the job' ,"error")
    end
end)

RegisterServerEvent('mng-garbage:server:MaterialExchange', function(amount, reward)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local HasItem = exports.ox_inventory:GetItemCount(src, Config.PayoutItem)
    if tonumber(HasItem) >= tonumber(amount) then
        if exports.ox_inventory:CanCarryItem(src, reward, amount) then
            if Player.Functions.RemoveItem(Config.PayoutItem, amount) then
                Player.Functions.AddItem(reward, amount)
            end
        end
    end
end)

lib.callback.register('mng-garbage:server:HasItem', function(source, Item, Amount)
    local src = source
    if exports.ox_inventory:GetItemCount(src, Item) >= Amount then
        return true
    else
        return false
    end
end)