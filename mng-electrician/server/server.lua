local QBCore = exports['qb-core']:GetCoreObject()
local Jobs = {}
local Stages = {
    [1] = {name="Head to the Repair Location.", isDone = false, id=1},
    [2] = {name="Repair the Electrical Boxes.", isDone = false, id=2},
    [3] = {name="Return to the Depot and Get Paid.", isDone = false, id=3},
}
local SiteBlips = {}

function UpdateGroupStage(Group, Index)
    Jobs[Group].Stages[Index].isDone = true
    exports['qb-phone']:setJobStatus(Group, 'Electrician', Jobs[Group].Stages)
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
                    CurrentStops = 0,
                    TotalStops = 0,
                    CurrentRoute = 0,
                    TotalTargets = 0,
                    CurrentTargets = 0,
                    JobFinished = false,
                }
              exports['qb-phone']:setJobStatus(Group, 'Electrician', Jobs[Group].Stages)
            end
        end
      end
end

RegisterServerEvent('mng-electrician:server:CanStart', function()
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
                    Wait(250)
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
        local plate = "LSWAP"..tostring(math.random(100, 999))
        SetVehicleNumberPlateText(Veh, plate)
        SetVehicleDoorsLocked(Veh, 1)
        SetEntityDistanceCullingRadius(Veh, 999999999.0)
        Wait(500)
        vehID = NetworkGetNetworkIdFromEntity(Veh)
    end
    Jobs[Group].Truck = Veh
    Jobs[Group].TotalStops = TotalStops
    Wait(250)
    for i = 1, #Members do
    TriggerClientEvent('mng-electrician:client:SetTruck', Members[i], vehID)
    end
    NextStop(src)
end


function NextStop(src)
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Size = exports['qb-phone']:getGroupSize(Group)
    local vehID = NetworkGetNetworkIdFromEntity(Jobs[Group].Truck)
    local NextRoute = PickRandomRoute(src)
    local Members = exports['qb-phone']:getGroupMembers(Group)
    Jobs[Group].CurrentRoute = NextRoute
    Jobs[Group].TotalTargets = #Config.Locations[NextRoute].repair
    for k, v in pairs(Config.Locations[NextRoute].repair) do
        SiteBlips[k] = {
            coords = v,
            color = 49,
            alpha = 255,
            sprite = 1,
            scale = 0.4,
            label = "Electrical Repair",
            route = false,
            routeColor = 5,
        }
        exports['qb-phone']:CreateBlipForGroup(Group, "Repair"..k, SiteBlips[k])
    end
    local blip = {
        coords = Config.Locations[Jobs[Group].CurrentRoute].coords,
        color = 49,
        alpha = 255,
        sprite = 769,
        scale = 0.5,
        label = "Repair Site",
        route = true,
        routeColor = 49,
    }

    local message = "Head to the repair site!"
    exports['qb-phone']:pNotifyGroup(Group, "LS Water and Power", message, "fas fa-recycle", '#008FFF', 7500)
    exports['qb-phone']:CreateBlipForGroup(Group, "Repair", blip)
    for i = 1, #Members do
        TriggerClientEvent('mng-electrician:client:CreateRepairZone', Members[i], Jobs[Group].CurrentRoute)
        TriggerClientEvent('mng-electrician:client:CreateTargets', Members[i], Jobs[Group].CurrentRoute)
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

RegisterServerEvent('mng-electrician:server:InZone', function()
    local src = source
    local Group = exports['qb-phone']:GetGroupByMembers(src) 
    local Members = exports['qb-phone']:getGroupMembers(Group)
    exports['qb-phone']:RemoveBlipForGroup(Group, "Repair")
    if not Jobs[Group].Stages[1].isDone then
        UpdateGroupStage(Group, 1)
        for i = 1, #Members do
            TriggerClientEvent('mng-electrician:client:ClearZone', Members[i])
        end
    end
end)


function SendHome(src)
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Members = exports['qb-phone']:getGroupMembers(Group)
    Jobs[Group].Finished = true
    local blip = {
        coords = Config.PedList[1].coords,
        color = 49,
        alpha = 255,
        sprite = 769,
        scale = 0.5,
        label = "Return to LS Water and Power",
        route = true,
        routeColor = 49,
    }

    local message = "Head Back to the LS Water and Power to get paid!"
    exports['qb-phone']:pNotifyGroup(Group, "LS Water and Power", message, "fas fa-recycle", '#008FFF', 7500)
    exports['qb-phone']:CreateBlipForGroup(Group, "Return", blip)
end

RegisterServerEvent('mng-electrician:server:UpdateWork', function(Num)
    local src = source
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    Jobs[Group].CurrentTargets += 1
    exports['qb-phone']:RemoveBlipForGroup(Group, "Repair"..Num)
    if Jobs[Group].CurrentTargets >= Jobs[Group].TotalTargets then
        Jobs[Group].CurrentStops += 1
        if Jobs[Group].CurrentStops >= Jobs[Group].TotalStops then
            UpdateGroupStage(Group, 2)
            SendHome(src)
        else
            Jobs[Group].CurrentTargets = 0
            Jobs[Group].Stages = lib.table.deepclone(Stages)
            exports['qb-phone']:setJobStatus(Group, 'Garbage', Jobs[Group].Stages)
            NextStop(src)
        end
    end
end)

RegisterServerEvent('mng-electrician:server:UpdateTarget', function(Num, Status)
    local src = source
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Members = exports['qb-phone']:getGroupMembers(Group)
    for i = 1, #Members do
        TriggerClientEvent('mng-electrician:client:UpdateTarget', Members[i], Num, Status)
    end
end)

RegisterServerEvent('mng-electrician:server:EndJob', function()
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
                end
                for i = 1, #Members do
                    Player = QBCore.Functions.GetPlayer(Members[i])
                    Player.Functions.AddMoney("cash", PayoutCash, 'Electrician Payout')
                end
                DeleteEntity(Jobs[Group].Truck)
                exports['qb-phone']:RemoveBlipForGroup(Group, "Repair")
                exports['qb-phone']:RemoveBlipForGroup(Group, "Return")
                exports["qb-phone"]:resetJobStatus(Group)
                for i = 1, #SiteBlips do
                    exports['qb-phone']:RemoveBlipForGroup(Group, "Return"..i)
                end
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