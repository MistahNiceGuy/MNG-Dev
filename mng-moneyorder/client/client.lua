local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('mng-moneyorder:client:PurchaseOrder', function()
    local Input = lib.inputDialog('Order Amount:', {
        {type = 'number', label = '$', description = 'Money Order Amount', icon = 'dollar-sign', required = true,},
        {type = 'input', label = 'Receiver\'s CID', description = 'Citizen ID of the Receiver e.g. ZWH84968', icon = 'id-card', required = true,},
    })
    local Amount = Input[1]
    local Receiver = Input[2]
    Confirm(Amount, Receiver)
end)

function Confirm(Amount, Receiver)
    local Alert = lib.alertDialog({
        header = 'Are you sure you want to make a money order for $ '..Amount..' to CID'..Receiver..'?',
        content = 'Make sure the CID is correct, if you make a mistake you can cash in the money order for a '..Config.Penalty..'% fee.',
        centered = true,
        cancel = true
        })
        if Alert == 'confirm' then
            Cash = exports.ox_inventory:GetItemCount('cash')
            if Cash >= Amount then
                TriggerServerEvent('mng-moneyorder:server:GiveMO', Amount, Receiver)
            else
                lib.notify({
                    title = 'Not Enough Cash',
                    description = 'Make Sure You Have $'..Amount..' In Your Pockets',
                    type = 'error'
                })
            end
    
        end
end

-- RegisterNetEvent('mng-moneyorder:client:ConfirmCashIn', function(Amount, Slot, Inv, Type)
--     local Penalty = Amount * (1.00 - (0.01 * Config.Penalty))
--     local Alert = nil
--     if Type == 'Penalty' then
--         Alert = lib.alertDialog({
--             header = 'You are able to cash in a money order you wrote and will take a '..Config.Penalty..'% penalty',
--             content = 'You receive $'..Penalty..' out of the total amount $'..Amount..'. Are you sure?',
--             centered = true,
--             cancel = true
--             })
--     else
--         Alert = lib.alertDialog({
--             header = 'You are able to cash in a money order for $'..Amount,
--             content = 'Are you sure?',
--             centered = true,
--             cancel = true
--             })
--     end
--         if Alert == 'confirm' and Type == 'Penalty' then
--             TriggerServerEvent('mng-moneyorder:server:CashIn', Penalty, Slot, Inv)
--         elseif Alert == 'confirm' and Type ~= 'Penalty' then
--             TriggerServerEvent('mng-moneyorder:server:CashIn', Amount, Slot, Inv)
--         end
-- end)



lib.callback.register('mng-moneyorder:client:CashIn', function(isPenalty, Amount)
    local Penalty = Amount * (1.00 - (0.01 * Config.Penalty))
    local Alert = nil
    if isPenalty then
        Alert = lib.alertDialog({
            header = 'You are able to cash in a money order you wrote and will take a '..Config.Penalty..'% penalty',
            content = 'You receive $'..Penalty..' out of the total amount $'..Amount..'. Are you sure?',
            centered = true,
            cancel = true
            })
    else
        Alert = lib.alertDialog({
            header = 'You are able to cash in a money order for $'..Amount,
            content = 'Are you sure?',
            centered = true,
            cancel = true
            })
    end
    if Alert == 'confirm' then
        return true
    end
    return false
end)