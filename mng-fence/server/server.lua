local QBCore = exports['qb-core']:GetCoreObject()
local CurrentLocation = nil

CreateThread(function()
    CurrentLocation = MySQL.query.await('SELECT Location FROM pedlocations WHERE ped = ?', { 'Fence' })
    while CurrentLocation == nil do
        Wait(50)
    end
    if CurrentLocation[1] == nil then
        MySQL.insert('INSERT INTO pedlocations (`Ped`, `Location`) VALUES (?, ?)', {
            'Fence',
            1,
        })
    end
end)

RegisterServerEvent('mng-fence:server:GetPedLocation', function()
    local src = source
    CurrentLocation = MySQL.query.await('SELECT Location FROM pedlocations WHERE ped = ?', { 'Fence' })
    while CurrentLocation[1] == nil do
        Wait(50)
    end
    TriggerClientEvent('mng-fence:client:UpdateLocation', src, CurrentLocation[1].Location)
end)

lib.callback.register('mng-fence:server:GetItems', function(source, Item)
    local src = source
    local Amount = exports.ox_inventory:GetItemCount(src, Item)
    return Amount
end)

RegisterServerEvent('mng-fence:server:SellItems', function(Item, Amount, Total)
    local src = source
    local Cash = (Amount * Config.SellList[Item].Price)
    if exports.ox_inventory:RemoveItem(src, Item, Amount) and Cash == Total then
        exports.ox_inventory:AddItem(src, 'cash', Cash)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Not Enough!',
            description = 'You didn\'t have enough '..Config.SellList[Item].Label,
            type = 'error'
        })
    end
end)

RegisterServerEvent('mng-fence:server:GiveItems', function(Item, Amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Rep = Player.PlayerData.metadata["fencerep"] + (Amount * Config.MissionList[Item].Rep)
    if exports.ox_inventory:RemoveItem(src, Item, Amount) then
        Player.Functions.SetMetaData('fencerep', Rep)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Not Enough!',
            description = 'You didn\'t have enough '..Config.MissionList[Item].Label,
            type = 'error'
        })
    end
end)

RegisterServerEvent('mng-fence:server:NewLocation', function()
    local NewLocation = math.random(1, #Config.Ped.Coords)
    while CurrentLocation[1].Location == NewLocation do
        NewLocation = math.random(1, #Config.Ped.Coords)
    end
    CurrentLocation[1].Location = NewLocation
    MySQL.update('UPDATE pedlocations SET Location = ? WHERE Ped = ?', { CurrentLocation[1].Location, 'Fence' })
    TriggerClientEvent('mng-fence:client:UpdateLocation', -1, CurrentLocation[1].Location)
    TriggerClientEvent('mng-fence:client:HandlePed', -1)
end)