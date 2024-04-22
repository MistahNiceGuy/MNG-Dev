local QBCore = exports['qb-core']:GetCoreObject()
local Jobs = {}
local Stages = {
    [1] = {name="Head to the Broken Down Vehicle.", isDone = false, id=1},
    [2] = {name="Return Vehicle to Depot.", isDone = false, id=2},
    [3] = {name="Unload and Impound the Vehicle.", isDone = false, id=3},
}

function UpdateGroupStage(Group, Index)
    Jobs[Group].Stages[Index].isDone = true
    exports['qb-phone']:setJobStatus(Group, 'Towing', Jobs[Group].Stages)
  end

function StartJob(src)
    local Veh = CreateVehicle(Config.Truck.Model, Config.Truck.Spawn.x, Config.Truck.Spawn.y, Config.Truck.Spawn.z, Config.Truck.Spawn.w, true, true)
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Size = exports['qb-phone']:getGroupSize(Group)
    local Members = exports['qb-phone']:getGroupMembers(Group)
    local vehID = nil
    while not DoesEntityExist(Veh) do
        Wait(25)
    end
    if DoesEntityExist(Veh) then
        local plate = "TOWING"..tostring(math.random(01, 99))
        SetVehicleNumberPlateText(Veh, plate)
        SetVehicleDoorsLocked(Veh, 1)
        SetEntityDistanceCullingRadius(Veh, 999999999.0)
        Wait(500)
        vehID = NetworkGetNetworkIdFromEntity(Veh)
        Jobs[Group].Truck = Veh
    end
    Wait(250)
    for i = 1, #Members do
        TriggerClientEvent('mng-towing:client:SetTruck', Members[i], vehID)
        TriggerClientEvent('mng-towing:client:CreateDepotZone', Members[i])
    end
    TriggerEvent('mng-towing:server:SetGroupStatus', 'IsWorking', true, src)   
    exports['qb-phone']:setJobStatus(Group, 'Towing', Jobs[Group].Stages)
    NextStop(src)
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
                CurrentRoute = 0,
                TargetVeh = nil,
                JobFinished = 0,
                TotalStops = 0,
                MaxStops = math.random(Config.MinStops, Config.MaxStops)
              }
              exports['qb-phone']:setJobStatus(Group, 'Towing', Jobs[Group].Stages)
            end
        end
      end
end

function NextStop(src)
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Size = exports['qb-phone']:getGroupSize(Group)
    local NextRoute = PickRandomRoute(src)
    local Members = exports['qb-phone']:getGroupMembers(Group)
    local Veh = CreateVehicle(Config.Models[math.random(1, #Config.Models)], Config.Target[NextRoute].coords.x, Config.Target[NextRoute].coords.y, Config.Target[NextRoute].coords.z, Config.Target[NextRoute].coords.w, true, true)
    Jobs[Group].CurrentRoute = NextRoute
    Jobs[Group].TargetVeh = Veh
    local blip = {
        coords = Config.Target[Jobs[Group].CurrentRoute].coords,
        color = 2,
        alpha = 255,
        sprite = 68,
        scale = 0.5,
        label = "Broken Down Vehicle",
        route = true,
        routeColor = 2,
    }
    while not DoesEntityExist(Veh) do
        Wait(25)
    end
    local vehID = NetworkGetNetworkIdFromEntity(Veh)
    SetEntityDistanceCullingRadius(Veh, 999999999.0)
    local message = "Head to the broken down vehicle!"
    exports['qb-phone']:pNotifyGroup(Group, "Towing Dispatch", message, "fas fa-truck-pickup", '#008FFF', 7500)
    exports['qb-phone']:CreateBlipForGroup(Group, "TowTarget", blip)
    for i = 1, #Members do
        TriggerClientEvent('mng-towing:client:SetTargetVeh', Members[i], vehID)
    end
end

function PickRandomRoute(src)
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local NewRoute = math.random(1, #Config.Target)
    while NewRoute == Jobs[Group].CurrentRoute do
        NewRoute = math.random(1, #Config.Target)
        Wait(250)
    end
    return NewRoute
end

RegisterServerEvent('mng-towing:server:CanStart', function()
    local src = source
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Size = nil
    local Leader = nil
    local Status = nil
    if Jobs[Group] ~= nil then
        TriggerClientEvent('QBCore:Notify', src, 'You are already working a route!', 'error')
        return
    end
    if Group == nil then
        TriggerClientEvent('QBCore:Notify', src, 'You need to be in a group to start this job!', 'error')
    else
        if exports['qb-phone']:getJobStatus(Group) == 'WAITING' then
            Leader = exports['qb-phone']:GetGroupLeader(Group)
            Size = exports['qb-phone']:getGroupSize(Group)
            Status = exports['qb-phone']:getJobStatus(Group)
            if Size > Config.MaxGroupSize then
                TriggerClientEvent('QBCore:Notify', src, 'You can only have '..Config.MaxGroupSize..' people working this job!', 'error')
                return
            else
                if src == Leader then
                    if Status ~= 'WAITING' then
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
        else
            TriggerClientEvent('QBCore:Notify', src, 'Your group is already working another job!', 'error')
        end
    end
end)

RegisterServerEvent('mng-towing:server:SendHome', function(ServSource)
    local src = source
    if ServSource ~= nil then
        src = ServSource
    end
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Members = exports['qb-phone']:getGroupMembers(Group)
    Jobs[Group].Finished = true
    local blip = {
        coords = Config.PedList[1].coords,
        color = 2,
        alpha = 255,
        sprite = 68,
        scale = 0.5,
        label = "Return to Tow Depot",
        route = true,
        routeColor = 2,
    }

    local message = "Bring the car back to the depot!!"
    exports['qb-phone']:pNotifyGroup(Group, "Towing Dispatch", message, "fas fa-truck-pickup", '#008FFF', 7500)
    exports['qb-phone']:RemoveBlipForGroup(Group, "TowTarget")
    exports['qb-phone']:CreateBlipForGroup(Group, "TowHome", blip)
    UpdateGroupStage(Group, 1)
end)

RegisterServerEvent('mng-towing:server:UpdateJob', function()
    local src = source
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    exports['qb-phone']:RemoveBlipForGroup(Group, "TowHome")
    Jobs[Group].TotalStops = Jobs[Group].TotalStops + 1
    if Jobs[Group].TotalStops >= Jobs[Group].MaxStops then
        local message = "I don\'t have anymore jobs for you, talk to me to get paid."
        exports['qb-phone']:pNotifyGroup(Group, "Towing Dispatch", message, "fas fa-truck-pickup", '#008FFF', 7500)
        TriggerEvent('mng-towing:server:SendHome', src)
    else
        NextStop(src)
    end 
end)

RegisterServerEvent('mng-towing:server:EndJob', function()
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
                for i = 1, Jobs[Group].TotalStops do
                    PayoutCash = PayoutCash + math.random(Config.PayMin, Config.PayMax)
                end
                    for i = 1, #Members do
                        Player = QBCore.Functions.GetPlayer(Members[i])
                        Player.Functions.AddMoney("cash", PayoutCash, 'Tow Job Payout')
                        TriggerEvent('mng-towing:client:ClearStatus', Members[i])
                    end
                    DeleteEntity(Jobs[Group].Truck)
                    exports['qb-phone']:RemoveBlipForGroup(Group, "TowTarget")
                    exports['qb-phone']:RemoveBlipForGroup(Group, "TowHome")
                    exports['qb-phone']:resetJobStatus(Group)
                    Jobs[Group] = nil
            else
                TriggerClientEvent('QBCore:Notify', src, 'You must have all group members present!' ,"error")
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'You must bring the tow truck back!' ,"error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'The Leader must end the job' ,"error")
    end
end)

RegisterServerEvent('mng-towing:server:SetGroupStatus', function(Status, State, ServSrc)
    local src = source
    if ServSrc ~= nil then
        src = ServSrc
    end
    local Group = exports['qb-phone']:GetGroupByMembers(src)
    local Members = exports['qb-phone']:getGroupMembers(Group)
    if Status == 'TowLoaded' and State == true and Jobs[Group].Stages[1].isDone ~= true then
        UpdateGroupStage(Group, 1)
    elseif
        Status == 'InDepotZone' and State == true and Jobs[Group].Stages[1].isDone and not Jobs[Group].Stages[2].isDone then
        UpdateGroupStage(Group, 2)
    elseif
        Status == 'TowLoaded' and State == false and Jobs[Group].Stages[1].isDone and Jobs[Group].Stages[2].isDone and not Jobs[Group].Stages[3].isDone then
        Jobs[Group].Stages = lib.table.deepclone(Stages)
        exports['qb-phone']:setJobStatus(Group, 'Towing', Jobs[Group].Stages)
    end
    for i = 1, #Members do
        TriggerClientEvent('mng-towing:client:SetStatus', Members[i], Status, State)
    end
end)