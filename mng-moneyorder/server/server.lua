local QBCore = exports['qb-core']:GetCoreObject()

local hookId = exports.ox_inventory:registerHook('createItem', function(payload)
    local metadata = payload.metadata
    return metadata
end, {
    print = false,
    itemFilter = {
        moneyorder = true
    }
})

RegisterServerEvent('mng-moneyorder:server:GiveMO', function(amount, Receiver)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local SourceID = Player.PlayerData.citizenid
    local Target = QBCore.Functions.GetPlayerByCitizenId(Receiver) or QBCore.Functions.GetOfflinePlayerByCitizenId(Receiver)
    if SourceID == Receiver then
        TriggerClientEvent('QBCore:Notify', src, "You can not write a money order to yourself!", "error")
        return
    end
    if Target == null then
        TriggerClientEvent('QBCore:Notify', src, "Entered CID does not belong to anyone!", "error")
        return
    end
    local Name = Target.PlayerData.charinfo.firstname..' '..Target.PlayerData.charinfo.lastname
    local success = exports.ox_inventory:RemoveItem(src, 'cash', amount)
    if success then
        exports.ox_inventory:AddItem(src, 'moneyorder', 1, {Source = SourceID, Amount = amount, CID = string.upper(Receiver), description = 'Amount: '..amount..' Receiver: '..Name})
    end
end)


exports('cashmo', function(event, item, inventory, slot, data)
    local Player = QBCore.Functions.GetPlayer(inventory.id)
    local SourceID = Player.PlayerData.citizenid
    Slot = exports.ox_inventory:GetSlot(inventory.id, slot)
    MetaData = Slot.metadata
    -- Player is attempting to use the item.
    -- if event == 'usingItem' then
    --     if MetaData.CID ~= SourceID and MetaData.Source == SourceID then
    --         TriggerClientEvent('mng-moneyorder:client:ConfirmCashIn',inventory.id, MetaData.Amount, slot, inventory.id, 'Penalty')
    --     elseif MetaData.CID == SourceID and MetaData.Source ~= SourceID then
    --         TriggerClientEvent('mng-moneyorder:client:ConfirmCashIn',inventory.id, MetaData.Amount, slot, inventory.id, 'Full')
    --     else
    --         TriggerClientEvent('ox_lib:notify', inventory.id, {
    --             title = 'You can not cash this money order!',
    --             description = 'This was not written by or for you!',
    --             type = 'error'
    --         })
    --     end
    -- end

    if event == 'usingItem' then
        local canCash = (MetaData.CID ~= SourceID and MetaData.Source == SourceID) or (MetaData.CID == SourceID and MetaData.Source ~= SourceID) or false
        if canCash then
            local isPenalty = MetaData.CID ~= SourceID and MetaData.Source == SourceID or false
            local Confirm = lib.callback.await('mng-moneyorder:client:CashIn', inventory.id, isPenalty, MetaData.Amount)
            if Confirm then
                local Amount = isPenalty and math.round((MetaData.Amount * (1.00 - (0.01 * Config.Penalty)))) or MetaData.Amount
                exports.ox_inventory:AddItem(inventory.id, 'cash', Amount)
            else
                TriggerClientEvent('ox_lib:notify', inventory.id, {
                    title = 'Cancelled.',
                    type = 'error'
                })
                return false
            end
        else
            TriggerClientEvent('ox_lib:notify', inventory.id, {
                title = 'You can not cash this money order!',
                description = 'This was not written by or for you!',
                type = 'error'
            })
            return false
        end
    end
end)

function Payout(Amount, Slot, src)
    if exports.ox_inventory:RemoveItem(src, 'moneyorder', 1, nil, Slot, false) then
        exports.ox_inventory:AddItem(src, 'cash', Amount)
    end
end

RegisterServerEvent('mng-moneyorder:server:CashIn', function(Amount, Slot, Inv)
    local success, response = exports.ox_inventory:RemoveItem(Inv, 'moneyorder', 1, nil, Slot, false)
    if success then
        exports.ox_inventory:AddItem(Inv, 'cash', Amount)
    end
end)