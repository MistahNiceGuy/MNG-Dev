local QBCore = exports['qb-core']:GetCoreObject()
local USB = {
    ['bruteforce'] = {Label = 'Brute Force USB', Difficulty = 1, Guesses = 7, ServerEvent = 'BFFinish'},
    ['ddos'] = {Label = 'DDOS USB', Difficulty = 1, Guesses = 7, ServerEvent = 'DDFinish'},
    ['keylogger'] = {Label = 'Key Logger USB', Difficulty = 1, Guesses = 9, ServerEvent = 'KLFinish'},
    ['codeinjector'] = {Label = 'Code Injector USB', Difficulty = 2, Guesses = 10, ServerEvent = 'CIFinish'},
}
local KLHook = exports.ox_inventory:registerHook('createItem', function(payload)
    local metadata = {
        ATM = 0,
        Ready = 'False',
    }
    return metadata
end, {
    print = false,
    itemFilter = {
        keylogger = true,
    }
})

local USBHook = exports.ox_inventory:registerHook('createItem', function(payload)
    local metadata = {
        Uses = 3,
    }
    return metadata
end, {
    print = false,
    itemFilter = {
        bruteforce = true,
        codeinjector = true,
        ddos = true,
    }
})

RegisterServerEvent('mng-atmrobbery:server:BruteForce', function(ID, Coords)
    local src = source
    local Ent = NetworkGetEntityFromNetworkId(ID)
    local Slot = exports.ox_inventory:GetSlotIdWithItem(src, 'bruteforce')
    local Item = exports.ox_inventory:GetSlot(src, Slot)
    Entity(Ent).state.Coords = Coords
    if Entity(Ent).state.Hacked then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Security Protocol',
            description = 'This ATM is out of order due to a security breach.',
            type = 'error'
        })
        return
    end
    if not Entity(Ent).state.Hacked then
        if Item.metadata.Uses > 1 then
            exports.ox_inventory:SetMetadata(src, Slot, {Uses = Item.metadata.Uses - 1})
            TriggerClientEvent('mng-atmrobbery:client:StartMiniGame', src, ID, 'bruteforce')
        elseif Item.metadata.Uses == 1 then
            exports.ox_inventory:RemoveItem(src, 'bruteforce', 1, {Uses = 1}, Slot)
            TriggerClientEvent('mng-atmrobbery:client:StartMiniGame', src, ID, 'bruteforce')
        end
    end
end)

RegisterServerEvent('mng-atmrobbery:server:BFFinish', function(ID, Success)
    local src = source
    local Ent = NetworkGetEntityFromNetworkId(ID)
    if Success then
        TriggerClientEvent('ox_lib:notify', src,{
            title = 'Brute Force Inititated',
            description = 'Program Running',
            type = 'success'
        })
        TriggerClientEvent('mng-atmrobbery:client:Alert', src, ID)
        Entity(Ent).state.Hacked = true
        TriggerClientEvent('mng-atmrobbery:client:BFCountDown', src, ID)
    else
        FailedAttempt(src, Ent)
    end
end)

RegisterServerEvent('mng-atmrobbery:server:DDOS', function(ID, Coords)
    local src = source
    local Ent = NetworkGetEntityFromNetworkId(ID)
    local Slot = exports.ox_inventory:GetSlotIdWithItem(src, 'ddos')
    local Item = exports.ox_inventory:GetSlot(src, Slot)
    Entity(Ent).state.Coords = Coords
    if Entity(Ent).state.Hacked then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Security Protocol',
            description = 'This ATM is out of order due to a security breach.',
            type = 'error'
        })
        return
    end
    if Item.metadata.Uses > 1 then
        exports.ox_inventory:SetMetadata(src, Slot, {Uses = Item.metadata.Uses - 1})
        TriggerClientEvent('mng-atmrobbery:client:StartMiniGame', src, ID, 'ddos')
    elseif Item.metadata.Uses == 1 then
        exports.ox_inventory:RemoveItem(src, 'ddos', 1, {Uses = 1}, Slot)
        TriggerClientEvent('mng-atmrobbery:client:StartMiniGame', src, ID, 'ddos')
    end
end)

RegisterServerEvent('mng-atmrobbery:server:DDFinish', function(ID, Success)
    local src = source
    local Ent = NetworkGetEntityFromNetworkId(ID)
    if Success then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'DDOS Initiated',
            description = 'Alarm Sytem Delayed',
            type = 'success'
        })
        Entity(Ent).state.Delay = Config.DDOSDelay * 1000 * 60
    else
        FailedAttempt(src, Ent)
    end
end)

RegisterServerEvent('mng-atmrobbery:server:KeyLogger', function(ID, Coords)
    local src = source
    local Ent = NetworkGetEntityFromNetworkId(ID)
    local Slot = exports.ox_inventory:GetSlotIdWithItem(src, 'keylogger')
    local Item = exports.ox_inventory:GetSlot(src, Slot)
    Entity(Ent).state.Coords = Coords
    if Entity(Ent).state.Hacked then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Security Protocol',
            description = 'This ATM is out of order due to a security breach.',
            type = 'error'
        })
        return
    end
    if Entity(Ent).state.Keylogged then
        if exports.ox_inventory:RemoveItem(src, 'keylogger', 1, {ATM = Ent, Ready = 'True'}) then
            Entity(Ent).state.Hacked = true
            Entity(Ent).state.Reward = true
            TriggerClientEvent('mng-atmrobbery:client:Alert', src, ID)
            Entity(Ent).state.Keylogged = false
            Payout(src, Ent)
        end
    elseif not Entity(Ent).state.Keylogged then
        if exports.ox_inventory:RemoveItem(src, 'keylogger', 1, {ATM = 0, Ready = 'False'}) then
            TriggerClientEvent('mng-atmrobbery:client:StartMiniGame', src, ID, 'keylogger')
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = 'You don\'t have a suitable USB.',
            type = 'error'
        })
    end
end)

RegisterServerEvent('mng-atmrobbery:server:CollectKL', function(ID)
    local src = source
    local Ent = NetworkGetEntityFromNetworkId(ID)
    Entity(Ent).state.KLCollect = false
    Entity(Ent).state.KLToggle = false
    exports.ox_inventory:AddItem(src, 'keylogger', 1, {ATM = Ent, Ready = 'True'})
end)

RegisterServerEvent('mng-atmrobbery:server:KLFinish', function(ID, Success)
    local src = source
    local Ent = NetworkGetEntityFromNetworkId(ID)
    if Success then
        Entity(Ent).state.Keylogger = os.time()
        Entity(Ent).state.Keylogged = true
        Entity(Ent).state.KLToggle = true
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Keylogger Initiated',
            description = 'Return later to collect USB.',
            type = 'success'
        })
        TriggerClientEvent('mng-atmrobbery:client:KeyLoggerCD', src, ID)
    else
        FailedAttempt(src, Ent)
    end
end)

RegisterServerEvent('mng-atmrobbery:server:CodeInjector', function(ID, Coords)
    local src = source
    local Ent = NetworkGetEntityFromNetworkId(ID)
    local Slot = exports.ox_inventory:GetSlotIdWithItem(src, 'codeinjector')
    local Item = exports.ox_inventory:GetSlot(src, Slot)
    Entity(Ent).state.Coords = Coords
    if Entity(Ent).state.Hacked then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Security Protocol',
            description = 'This ATM is out of order due to a security breach.',
            type = 'error'
        })
        return
    end
    if Item.metadata.Uses > 1 then
        exports.ox_inventory:SetMetadata(src, Slot, {Uses = Item.metadata.Uses - 1})
        TriggerClientEvent('mng-atmrobbery:client:StartMiniGame', src, ID, 'codeinjector')
    elseif Item.metadata.Uses == 1 then
        exports.ox_inventory:RemoveItem(src, 'codeinjector', 1, {Uses = 1}, Slot)
        TriggerClientEvent('mng-atmrobbery:client:StartMiniGame', src, ID, 'codeinjector')
    end
end)

RegisterServerEvent('mng-atmrobbery:server:CIFinish', function(ID, Success)
    local src = source
    local Ent = NetworkGetEntityFromNetworkId(ID)
    if Success then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Code Injector Initiated',
            description = 'Alarm system delayed and system breached.',
            type = 'success'
        })
        Entity(Ent).state.Delay = Config.CodeInjectorDelay * 1000 * 60
        Entity(Ent).state.Hacked = true
        Entity(Ent).state.Reward = true
        TriggerClientEvent('mng-atmrobbery:client:Alert', src, ID)
        Payout(src, Ent)
    else
        FailedAttempt(src, Ent)
    end
end)

function FailedAttempt(src, Ent)
    if Entity(Ent).state.Attempts == nil then
        Entity(Ent).state.Attempts = 0
    end
    Entity(Ent).state.Attempts += 1
    if Entity(Ent).state.Attempts >= Config.ATMAttemps then
        Entity(Ent).state.Hacked = true
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Security Protocol',
            description = 'Multiple breaches detected, ATM shutting down.',
            type = 'error'
        })
        TriggerClientEvent('mng-atmrobbery:client:Alert', src, ID)
        return
    end
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Security Protocol',
        description = 'Potential Security Breach Detected',
        type = 'error'
    })
end

RegisterServerEvent('mng-atmrobbery:server:Finish', function(ID)
    local src = source
    local Ent = NetworkGetEntityFromNetworkId(ID)
    Payout(src, Ent)
end)

RegisterServerEvent('mng-atmrobbery:server:SetReward', function(ID)
    local src = source
    local Ent = NetworkGetEntityFromNetworkId(ID)
    if Entity(Ent).state.Hacked then
        Entity(Ent).state.Reward = true
        SetTimeout(0, function() RewardTimer(Ent) end)
    end
end)

function RewardTimer(Ent)
    Wait(Config.LockDownTime * 1000 * 60)
    Entity(Ent).state.Reward = false
end

lib.callback.register('mng-atmrobbery:server:GetDelay', function(source, ID)
    local Ent = NetworkGetEntityFromNetworkId(ID)
    return Entity(Ent).state.Delay
end)

lib.callback.register('mng-atmrobbery:server:GetUSBInfo', function(source, HackType)
    return USB[HackType]
end)

lib.callback.register('mng-atmrobbery:server:GetKLTime', function(source, ID)
    return os.time()
end)

RegisterServerEvent('mng-atmrobbery:server:OpenATMUI', function(ID)
    local src = source
    local Ent = NetworkGetEntityFromNetworkId(ID)
    if Entity(Ent).state.Hacked then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Security Protocol',
            description = 'This ATM is out of order due to a security breach.',
            type = 'error'
        })
        return
    end
    TriggerClientEvent('qb-banking:client:atm:openUI', src)
end)

RegisterCommand('givekl', function()
    exports.ox_inventory:AddItem(1, 'keylogger', 1, {ATM = 0, Ready = 'False'}) --remove before live
end)

function Payout(src, Ent)
    local Amount = math.random(Config.MinPayout, Config.MaxPayout)
    if Entity(Ent).state.Hacked and Entity(Ent).state.Reward then
        exports.ox_inventory:AddItem(src, Config.PayoutItem, Amount)
        Entity(Ent).state.Reward = false
    end
end
