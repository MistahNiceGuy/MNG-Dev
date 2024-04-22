local QBCore = exports['qb-core']:GetCoreObject()
local Jobs = {}
local Stages = {
    [1] = {name="Deliver Packages.", isDone = false, id=1},
    [2] = {name="Return to the Depot and Get Paid.", isDone = false, id=2},
}
local SiteBlips = {}

function UpdateGroupStage(Group, Index)
    Jobs[Group].Stages[Index].isDone = true
    exports['qb-phone']:setJobStatus(Group, 'Delivery', Jobs[Group].Stages)
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
                    CurrentBoxes = 0,
                    CurrentMaxBoxes = 0,
                    CurrentStops = 0,
                    TotalStops = 0,
                    CurrentRoute = 0,
                    JobFinished = false,
                }
              exports['qb-phone']:setJobStatus(Group, 'Electrician', Jobs[Group].Stages)
            end
        end
      end
end

RegisterServerEvent('mng-delivery:server:CanStart', function()
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
    local TotalStops = math.random(Config.MinStops, Config.MaxStops)
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Members = exports['qb-phone']:getGroupMembers(Group)
    local vehID = nil

    while not DoesEntityExist(Veh) do
        Wait(25)
    end
    if DoesEntityExist(Veh) then
        local plate = "POSTOP"..tostring(math.random(10, 99))
        SetVehicleNumberPlateText(Veh, plate)
        SetVehicleDoorsLocked(Veh, 1)
        SetEntityDistanceCullingRadius(Veh, 999999999.0)
        Wait(500)
        vehID = NetworkGetNetworkIdFromEntity(Veh)
    end
    Jobs[Group].Truck = Veh
    Jobs[Group].TotalStops = TotalStops
    for i = 1, #Members do
    TriggerClientEvent('mng-delivery:client:CreateTruckTarget', Members[i], vehID)
    TriggerClientEvent('mng-delivery:client:SetTruck', Members[i])
    end
    NextStop(src)
end


function NextStop(src)
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local NextRoute = PickRandomRoute(src)
    local RouteBoxes = math.random(Config.MinBoxes, Config.MaxBoxes)
    local Members = exports['qb-phone']:getGroupMembers(Group)
    Jobs[Group].CurrentRoute = NextRoute
    Jobs[Group].CurrentMaxBoxes = RouteBoxes
    local blip = {
        coords = Config.Locations[Jobs[Group].CurrentRoute].coords,
        color = 56,
        alpha = 255,
        sprite = 478,
        scale = 0.5,
        label = "Delivery Route",
        route = true,
        routeColor = 56,
    }

    local message = "Head to the delivery!"
    exports['qb-phone']:pNotifyGroup(Group, "Post Op", message, "fas fa-box", '#008FFF', 7500)
    exports['qb-phone']:CreateBlipForGroup(Group, "Delivery", blip)
    for i = 1, #Members do
    TriggerClientEvent('mng-delivery:client:CreateDeliverZone', Members[i], Jobs[Group].CurrentRoute)
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

RegisterServerEvent('mng-delivery:server:UpdateBoxes', function()
    local src = source
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Members = exports['qb-phone']:getGroupMembers(Group)
    Jobs[Group].CurrentBoxes = Jobs[Group].CurrentBoxes + 1
    local message = "Boxes Delivered: "..Jobs[Group].CurrentBoxes..' / '..Jobs[Group].CurrentMaxBoxes
    exports['qb-phone']:pNotifyGroup(Group, "Post Op", message, "fas fa-box", '#008FFF', 7500)
    if Jobs[Group].CurrentBoxes >= Jobs[Group].CurrentMaxBoxes then
        Jobs[Group].CurrentStops = Jobs[Group].CurrentStops + 1
        exports['qb-phone']:RemoveBlipForGroup(Group, "Delivery")
        for i = 1, #Members do
        TriggerClientEvent('mng-delivery:client:ClearStatus', Members[i])
        TriggerClientEvent('mng-delivery:client:ClearZone', Members[i], Jobs[Group].CurrentRoute)
        Jobs[Group].CurrentBoxes = 0
        end
        if Jobs[Group].CurrentStops >= Jobs[Group].TotalStops then
            SendHome(src)
            UpdateGroupStage(Group, 1)
        else
            NextStop(src)
            Jobs[Group].Stages = lib.table.deepclone(Stages)
            exports['qb-phone']:setJobStatus(Group, 'Delivery', Jobs[Group].Stages)
        end
    end
end)

function SendHome(src)
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Members = exports['qb-phone']:getGroupMembers(Group)
    Jobs[Group].Finished = true
    local blip = {
        coords = Config.PedList[1].coords,
        color = 56,
        alpha = 255,
        sprite = 478,
        scale = 0.5,
        label = "Return to Post Op",
        route = true,
        routeColor = 56,
    }

    local message = "Head Back to the Warehouse to get paid!"
    exports['qb-phone']:pNotifyGroup(Group, "Post Op", message, "fas fa-box", '#008FFF', 7500)
    exports['qb-phone']:CreateBlipForGroup(Group, "PostOpHome", blip)
end

RegisterServerEvent('mng-delivery:server:EndJob', function()
    local src = source
    local Player = nil
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    if Group == nil or Jobs[Group] == nil then TriggerClientEvent('QBCore:Notify', src, 'You are not working right now!' ,"error") return end
    local Members = exports['qb-phone']:getGroupMembers(Group)
    local Leader = exports['qb-phone']:GetGroupLeader(Group)
    local PayoutCash = 0
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
                end
                for i = 1, #Members do
                    Player = QBCore.Functions.GetPlayer(Members[i])
                    TriggerClientEvent('mng-delivery:client:ClearStatus', Members[i])
                    Player.Functions.AddMoney("cash", PayoutCash, 'Post Op Delivery Payout')
                end
                DeleteEntity(Jobs[Group].Truck)
                exports['qb-phone']:RemoveBlipForGroup(Group, "PostOpHome")
                exports['qb-phone']:RemoveBlipForGroup(Group, "Delivery")
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

