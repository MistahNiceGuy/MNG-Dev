local QBCore = exports['qb-core']:GetCoreObject()
local Jobs = {}
local usedPlates = {}
local CoolDownCheck = {}

RegisterServerEvent('mng-pizzadelivery:server:StartJob', function(data)
    local src = source
    local chance = math.random(1, 100)
    if CoolDownCheck[src] ~= nil then
        if CoolDownCheck[src] == true then
            TriggerClientEvent('QBCore:Notify', src, 'You need to wait until I give you another job, make sure to finish your deliveries next time', "error", 10000)
            StartCoolDown(src)
            return
        end
    else
        CoolDownCheck[src] = false
    end
    if Jobs[src] == nil then
        Jobs[src] = {
            Deliveries = 0,
            DeliveriesFinished = 0,
            CurrentDelivery = 0,
            Vehicle = 0,
            AllFinished = false,
        }
        local coords = Config.VehicleSpawn.Coords
        local car = CreateVehicle(Config.Vehicles[data.vehicle].Model, coords.x, coords.y, coords.z, coords.w, true, true)
        while not DoesEntityExist(car) do
            Wait(25)
        end
        if DoesEntityExist(car) then
            local plate = GetRandomPlate()
            usedPlates[plate] = true
            SetVehicleNumberPlateText(car, plate)
            SetVehicleDoorsLocked(car, 1)
            SetEntityDistanceCullingRadius(car, 999999999.0)
            Wait(500)
            Jobs[src]['Vehicle'] = car
            Jobs[src]['Deliveries'] = GetMaxDeliveries(data.vehicle)
            Jobs[src]['CurrentDelivery'] = GetNewDelivery(src)
            CoolDownCheck[src] = true
            if chance <= Config.SpecialDeliveryChance then
                SpecialDelivery(src, data.vehicle, plate)
                return
            end
            TriggerClientEvent('QBCore:Notify', src, 'You have ' .. Jobs[src].Deliveries .. ' deliveries to make.', "success", 4000)
            if data.vehicle ~= 'Car' then
                TriggerClientEvent('mng-pizzadelivery:client:handleProps', src, Jobs[src].Deliveries, NetworkGetNetworkIdFromEntity(Jobs[src].Vehicle), 'create')
            end
            TriggerClientEvent('mng-pizzadelivery:client:setVeh', src, NetworkGetNetworkIdFromEntity(Jobs[src].Vehicle), plate, Jobs[src].Deliveries, data.vehicle)
            TriggerClientEvent('mng-pizzadelivery:client:CreateDeliverZone', src, Jobs[src]['CurrentDelivery'])
            TriggerClientEvent('mng-pizzadelivery:client:handleBlip', src, Config.DeliveryZones[Jobs[src]['CurrentDelivery']], 'create')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You are already working!', "error", 4000)
    end
end)

function GetRandomPlate()
    local plate = "PIZZA" .. tostring(math.random(100, 999))
    while usedPlates[plate] == true do
        plate = "PIZZA" .. tostring(math.random(100, 999))
        Wait(10)
    end
    return plate
end

function GetNewDelivery(src)
    local rand = math.random(1, #Config.DeliveryZones)
    while rand == Jobs[src].CurrentDelivery do
        rand = math.random(1, #Config.DeliveryZones)
        Wait(10)
    end
    return rand
end

function GetMaxDeliveries(VehType)
    local MaxDeliveries = math.random(Config.Vehicles[VehType].MinDeliveries, Config.Vehicles[VehType].MaxDeliveries)
    return MaxDeliveries
end

RegisterServerEvent('mng-pizzadelivery:server:UpdateDelivery', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local ExpGain = math.random(Config.MinExpGain, Config.MaxExpGain)
   TriggerEvent('mng-pizzadelivery:server:UpdateExp', ExpGain, src)
    Jobs[src]['DeliveriesFinished'] = Jobs[src]['DeliveriesFinished'] + 1
    TriggerClientEvent('mng-pizzadelivery:client:handleBlip', src, Config.DeliveryZones[Jobs[src]['CurrentDelivery']], 'delete')
    if Jobs[src]['DeliveriesFinished'] < Jobs[src]['Deliveries'] then
        Jobs[src]['CurrentDelivery'] = GetNewDelivery(src)
        TriggerClientEvent('mng-pizzadelivery:client:CreateDeliverZone', src, Jobs[src]['CurrentDelivery'])
        TriggerClientEvent('mng-pizzadelivery:client:handleBlip', src, Config.DeliveryZones[Jobs[src]['CurrentDelivery']], 'create')
        TriggerClientEvent('QBCore:Notify', src, 'You have a new delivery to make.', "success", 4000)
    else
        Jobs[src]['AllFinished'] = true
        TriggerClientEvent('mng-pizzadelivery:client:handleBlip', src, Config.PedList[1].coords, 'create')
        TriggerClientEvent('QBCore:Notify', src, 'You have made all of your deliveries. Return to the Pizza Shop to get paid.', "success", 4000)
        TriggerClientEvent('mng-pizzadelivery:client:ChangeStatus', src, 'All')
    end
end)

RegisterServerEvent('mng-pizzadelivery:server:UpdateExp', function(Amount, source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Exp = tonumber(Player.PlayerData.metadata['pizzaexp'])
    local Level = tonumber(Player.PlayerData.metadata['pizzalevel'])
    Exp = Exp + Amount
    
    if Exp >= Config.ExperiencePerLevel then
        Level = Level + 1
        Exp = Exp - Config.ExperiencePerLevel
        Player.Functions.SetMetaData('pizzalevel', Level)
        Player.Functions.SetMetaData('pizzaexp', Exp)
        TriggerClientEvent('QBCore:Notify', src, 'You have gained '..Amount..' Exp! You now have '..Exp..' Exp' , "success", 4000)
        TriggerClientEvent('QBCore:Notify', src, 'You have gained a level! You are now level '..Level, "success", 4000)
    else
        Player.Functions.SetMetaData('pizzaexp', Exp)
        TriggerClientEvent('QBCore:Notify', src, 'You have gained '..Amount..' Exp! You now have '..Exp..' Exp' , "success", 4000)
    end
end)

RegisterServerEvent('mng-pizzadelivery:server:EndJob', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local vehCoords = GetEntityCoords(Jobs[src].Vehicle)
    local dist = #(vehCoords - Config.PedList[1].coords)
    if dist < 25.0 then
        local payout = 0
        for i = 1, Jobs[src].DeliveriesFinished do
            payout = payout + math.random(Config.MinPayout, Config.MaxPayout)
        end
        payout = math.ceil(payout * (1.0 + Config.LevelPayoutIncrease))
        Player.Functions.AddMoney("cash", payout, 'Pizza Delivery Payout')
        if Config.EnableJobFinishExp and Jobs[src]['AllFinished'] then
            TriggerEvent('mng-pizzadelivery:server:UpdateExp', Config.JobFinishExpGain, src)
        end
        if Jobs[src]['AllFinished'] then
            CoolDownCheck[src] = false
        end
        TriggerClientEvent('mng-pizzadelivery:client:DestroyZone', src, Jobs[src].CurrentDelivery)
        TriggerClientEvent('mng-pizzadelivery:client:handleProps', src, 0, NetworkGetNetworkIdFromEntity(Jobs[src].Vehicle), 'clear')
        TriggerClientEvent('mng-pizzadelivery:client:handleBlip', src, 'delete')
        TriggerClientEvent('mng-pizzadelivery:client:ChangeStatus', src, 'Clear')
        Jobs[src] = nil
    else
        TriggerClientEvent('QBCore:Notify', src, 'You need to return the delivery vehicle!' , "error", 4000)
    end
end)

QBCore.Commands.Add("mngpizza", "Set a Player's Exp or Level (Admin Only)", {{name="id", help="Player ID"},{name="Stat", help="exp, level"},{name="Amount", help="Will set Exp or Level to this amount."},}, false, function(source, args)
	local id = tonumber(args[1])
	local Player = QBCore.Functions.GetPlayer(id)
    local src = source
    if Player then
        local name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        Player.Functions.SetMetaData('pizza'..string.lower(args[2]), args[3])
        TriggerClientEvent('QBCore:Notify', src,  "You have set "..name..'\'s pizza '..args[2]..' to '..args[3], "success")
    else
		TriggerClientEvent('QBCore:Notify', src,  "Player Is Not Online", "error")
	end
end, "admin")

function SpecialDelivery(src, veh, plate)
    Jobs[src]['Deliveries'] = 1
    Jobs[src]['CurrentDelivery'] = 1
    if veh ~= 'Car' then
        TriggerClientEvent('mng-pizzadelivery:client:handleProps', src, Jobs[src].Deliveries, NetworkGetNetworkIdFromEntity(Jobs[src].Vehicle), 'create')
    end
    TriggerClientEvent('mng-pizzadelivery:client:setVeh', src, NetworkGetNetworkIdFromEntity(Jobs[src].Vehicle), plate, Jobs[src].Deliveries, veh)
    TriggerClientEvent('mng-pizzadelivery:client:CreateSpecialZone', src, Jobs[src]['CurrentDelivery'])
    TriggerClientEvent('mng-pizzadelivery:client:handleBlip', src, Config.SpecialDelivery[Jobs[src]['CurrentDelivery']], 'create')
    TriggerClientEvent('QBCore:Notify', src, 'Deliver This Pizza to my Friend Clyde', "success", 7500)
end

function StartCoolDown(src)
    SetTimeout(Config.CoolDownTime * 1000)
    CoolDownCheck[src] = false
end
