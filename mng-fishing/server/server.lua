local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("fishingrod", function(source)
    TriggerClientEvent('mng-fishing:client:castrod', source)
end)

QBCore.Functions.CreateCallback('mng-fishing:UseBait', function(source, cb, BaitType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local FishingLevel = Player.PlayerData.metadata["fishinglevel"]
    if Config.Debug then
        print(BaitType)
    end
    if Player ~= nil then
        if not Config.ConsumeLure then
            if BaitType == 'lure' then
                if tonumber(FishingLevel) >= Config.LureLevel then
                    cb(true)
                    return
                else
                    TriggerClientEvent('QBCore:Notify', src, "You need to be Level "..Config.LureLevel..' to use a Lure', "error", 4000)
                    cb(false)
                    return
                end
            end
        end
        if Player.Functions.RemoveItem(BaitType, 1) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[BaitType], 'remove')
            cb(true)
        else
            cb(false)
        end
    end
end)

QBCore.Functions.CreateCallback('mng-fishing:CatchFish', function(source, cb, area, time, rain, BaitType, success)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local luck = Player.PlayerData.metadata["fishingskill2"]
    local LootTable = {}
    local chance = math.random(1, 100) + (luck * Config.RareChancePerLevel)
    local exp = math.random(Config.ExpMin, Config.ExpMax)
    if success == 'perfect' then
        exp = exp + Config.PerfectBonus
    end
    if chance >= (100 - Config.RareChance) then
        for k, v in pairs(Config.Fish['rare']) do
            table.insert(LootTable, Config.Fish['rare'][k])
        end
    else
        for k, v in pairs(Config.Fish[area]['247']) do
            table.insert(LootTable, Config.Fish[area]['247'][k])
        end
        if time >= Config.NightStart and time < 24 or time < Config.NightEnd and time >= 0 then
            for k, v in pairs(Config.Fish[area]['night']) do
                table.insert(LootTable, Config.Fish[area]['night'][k])
            end
        else
            for k, v in pairs(Config.Fish[area]['day']) do
                table.insert(LootTable, Config.Fish[area]['day'][k])
            end
        end
        if rain > 0 then
            for k, v in pairs(Config.Fish[area]['rain']) do
                table.insert(LootTable, Config.Fish[area]['rain'][k])
            end
        end
        if BaitType == 'lure' then
            for k, v in pairs(Config.Fish[area]['lure']) do
                table.insert(LootTable, Config.Fish[area]['lure'][k])
            end
        end
    end
    if Config.Debug then
        print('Loot Table: '..json.encode(LootTable))
        print('Luck: '..luck)
        print('Chance: '..chance)
        print('Area: '..area)
        print('Time: '..time)
        print('Rain: '..rain)
    end
    local loot = LootTable[math.random(1, #LootTable)]
    local ItemCheck = exports.ox_inventory:Items()
    if not ItemCheck[loot] then
        cb(false)
        print('ERROR! mng-fishing is trying to award an item that does not exist. Make sure you added all items to your QB Core shared items list! Item: '..loot)
    end
    if Player ~= nil then
        if exports.ox_inventory:CanCarryItem(src, loot, 1) then
            if exports.ox_inventory:AddItem(src, loot, 1) then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[loot], 'add')
                TriggerEvent('mng:server:UpdateExp', 'fishing', exp, src)
                cb(true)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end
end)

-- QBCore.Functions.CreateCallback('mng:server:Stats', function(source, cb, skill) -- ready to be used for any mng resource
-- 	local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     local cid = Player.PlayerData.citizenid
--     local name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
--     local entry = MySQL.query.await('SELECT * FROM mngskills WHERE cid = ?', { cid })
--     local entry2 = MySQL.query.await('SELECT * FROM mngecon WHERE id = ?', { 1 })
--     if entry2[1] == nil then
--         MySQL.insert('INSERT INTO mngecon (`id`, `fish`, `boxedfish`, `gamemeat`, `boxedgamemeat`, `beef`, `boxedbeef`, `chicken`, `boxedchicken`, `pork`, `boxedpork`, `wheat`, `boxedspice`, `spice`, `flour`, `gravel`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {0, 0, 0, 0, 0 ,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
--     end  
--     if entry[1] == nil then
--         MySQL.insert('INSERT INTO mngskills (`cid`, `name`, `fishinglevel`, `fishingexperience`, `fishingskillpoints`, `fishingskillone`, `fishingskilltwo`, `mininglevel`, `miningexperience`, `miningskillpoints`, `miningskillone`, `miningskilltwo`, `huntinglevel`, `huntingexperience`, `huntingskillpoints`, `huntingskillone`, `huntingskilltwo`, `truckinglevel`, `truckingexperience`, `truckingskillpoints`, `truckingskillone`, `truckingskilltwo`, `farminglevel`, `farmingexperience`, `farmingskillpoints`, `farmingskillone`, `farmingskilltwo`, `lumberjackinglevel`, `lumberjackingexperience`, `lumberjackingskillpoints`, `lumberjackingskillone`, `lumberjackingskilltwo`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {cid, name, 0, 0 ,0 ,0, 0, 0, 0 ,0 ,0, 0, 0, 0 ,0 ,0, 0, 0, 0 ,0 ,0, 0, 0, 0 ,0 ,0, 0, 0, 0 ,0 ,0, 0})
--     end  
--     local result = MySQL.query.await('SELECT * FROM mngskills WHERE cid = ?', { cid })
--     local stats = {}
--     if result[1] ~= nil then
--         stats = {level = result[1][skill..'level'], experience = result[1][skill..'experience'], skillpoints = result[1][skill..'skillpoints'], skillone = result[1][skill..'skillone'], skilltwo = result[1][skill..'skilltwo'], name = result[1]['name']}
--     end
--     cb(stats)
-- end)

-- QBCore.Functions.CreateCallback('mng:server:StockLevels', function(source, cb, econ) -- ready to be used for any mng resource
-- 	local src = source
--     local entry = MySQL.query.await('SELECT * FROM mngecon WHERE id = ?', { 1 })
--     print('trig')
--     if entry[1] == nil then
--         MySQL.insert('INSERT INTO mngecon (`id`, `fish`, `boxedfish`, `gamemeat`, `boxedgamemeat`, `beef`, `boxedbeef`, `chicken`, `boxedchicken`, `pork`, `boxedpork`, `wheat`, `boxedspice`, `spice`, `flour`, `gravel`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {0, 0, 0, 0, 0 ,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
--     end  
--     local stock = {}
--     if entry[1] ~= nil then
--         stock = {fish = entry[1]['fish'], gamemeat = entry[1]['gamemeat'], beef = entry[1]['beef'], chicken = entry[1]['chicken'], pork = entry[1]['pork'], wheat = entry[1]['wheat'], rawspice = entry[1]['rawspice'], spice = entry[1]['spice'], flour = entry[1]['flour'], gravel = entry[1]['gravel'], }    
--     end
--     cb(stock)
-- end)

RegisterServerEvent('mng:server:UpdateExp', function(skill, amount, source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local Level = Player.PlayerData.metadata["fishinglevel"]
    local Experience = Player.PlayerData.metadata["fishingexperience"]
    local Skill1 = Player.PlayerData.metadata["fishingskill1"]
    local Skill2 = Player.PlayerData.metadata["fishingskill2"]
    local SkillPoints = Player.PlayerData.metadata["fishingskillpoints"]
    Experience = Experience + amount
    if (tonumber(Experience) + amount) >= Config.ExpPerLevel then
        if tonumber(Level) < Config.MaxLevel then
            Experience = Experience - Config.ExpPerLevel
            Level = Level + 1
            SkillPoints = SkillPoints + 1
            Player.Functions.SetMetaData('fishingexperience', Experience)
            Player.Functions.SetMetaData('fishinglevel', Level)
            Player.Functions.SetMetaData('fishingskillpoints', SkillPoints)
            TriggerClientEvent('QBCore:Notify', src, "You have gained "..amount..' fishing experience and gained a level!', "success", 4000)
        end
    else
        Player.Functions.SetMetaData('fishingexperience', Experience)
        TriggerClientEvent('QBCore:Notify', src, "You have gained "..amount..' fishing experience', "success", 4000)
    end
end)

RegisterServerEvent('mng:server:SpendSkill', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local Skill = Player.PlayerData.metadata[data.skill]
    local SkillPoints = Player.PlayerData.metadata["fishingskillpoints"]
    if SkillPoints > 0 then
        SkillPoints = SkillPoints - 1
        Skill = Skill + 1
        Player.Functions.SetMetaData('fishingskillpoints', SkillPoints)
        Player.Functions.SetMetaData(data.skill, Skill)
        TriggerClientEvent('QBCore:Notify', src, "You have increased your skill level!", "success", 4000)
    else
        TriggerClientEvent('QBCore:Notify', src, "You don\'t have any skill points to spend!", "error", 4000)
    end
end)

QBCore.Functions.CreateCallback('mng:server:BuyItem', function(source, cb, data, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player ~= nil then
        if Player.PlayerData.money[data.paymenttype] >= (data.amount * Config.ShopPrices[item]) then
            print(src, type(item), data.amount)
            if exports.ox_inventory:CanCarryItem(src, item, data.amount) then
                if Player.Functions.AddItem(item, data.amount) then
                    Player.Functions.RemoveMoney(data.paymenttype, (data.amount * Config.ShopPrices[item]))
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', data.amount)
                    cb('success')
                else
                    cb('weight')
                end
            else
                cb('weight')
            end
        else
            cb('money')
        end
    end
end)

-- QBCore.Commands.Add("mngsetstat", "Set a Player's Stat (Admin Only)", {{name="id", help="Player ID"},{name="Skill", help="fishing, mining, lumberjacking, trucking, farming, hunting"}, {name="Stat", help="level, experience, skillpoints"},{name="Amount", help="Will add this to the current amount."},}, false, function(source, args)
-- 	local id = tonumber(args[1])
-- 	local Player = QBCore.Functions.GetPlayer(id)
--     local src = source
--     Wait(200)
--     if Player then
--         local cid = Player.PlayerData.citizenid
--         local entry = MySQL.query.await('SELECT * FROM mngskills WHERE cid = ?', { cid })
--         local name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
--         MySQL.update('UPDATE mngskills SET '..args[2]..args[3]..' = ? WHERE cid = ?', { (entry[1][args[2]..args[3]] + args[4]), cid })
--         if args[3] == 'level' then
--             MySQL.update('UPDATE mngskills SET '..args[2]..'skillpoints = ? WHERE cid = ?', { (entry[1][args[2]..'skillpoints'] + args[4]), cid })
--         end
--         QBCore.Functions.Notify(src,  "You have set "..name..' '..args[2]..args[3]..' to '..(entry[1][args[2]..args[3]] + args[4]), "success")
--     else
-- 		QBCore.Functions.Notify(src,  "Player Is Not Online", "error")
-- 	end
-- end, "admin")

-- QBCore.Commands.Add("mngsetstock", "Set Stock Amount for Economy (Admin Only)", {{name="Type", help="fish, gamemeat, beef, chicken, pork, wheat, rawspice, spice, flour, gravel"}, {name="Amount", help="Will add this to the current amount."},}, false, function(source, args)
--     local src = source
--     local entry = MySQL.query.await('SELECT * FROM mngecon WHERE id = ?', { 1 })
--     MySQL.update('UPDATE mngecon SET '..args[1]..' = ? WHERE id = ?', { (entry[1][args[1]] + args[2]), 1 })
--     QBCore.Functions.Notify(src,  "You have set "..args[1]..' to '..(entry[1][args[1]] + args[2]), "success")
-- end, "admin")

RegisterServerEvent('mng-fishing:server:SellAllFish', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    -- local result = MySQL.query.await('SELECT * FROM mngskills WHERE cid = ? ', { cid })
    local Level = Player.PlayerData.metadata["fishinglevel"]
    local payout = 0
    local PlayerItems = exports.ox_inventory:GetInventoryItems(src)
    -- print(json.encode(PlayerItems,{indent = true}))
    for k, v in pairs(Config.FishPrices) do
        local amount = exports.ox_inventory:GetItemCount(src, k)
        if amount > 0 then
            if Player.Functions.RemoveItem(k, amount) then
                payout = payout + (amount * v)
                Wait(500)
            end
        end
    end
    if payout ~= 0 then
        if Config.EnableFishValuePerLevel then
            payout = payout * (1.0 + (Config.FishValuePerLevel * Level))
        end 
        payout = math.ceil(payout)
        Player.Functions.AddMoney('cash', payout)
        -- MySQL.update('UPDATE mngecon SET fish = ? WHERE id = ?', { fishtotal, 1 })
    end
end)

--[[
    to do:
        make fishing menu to eventually place econ order
        set pricing in loot table
        eventually make ice chest storage item for fish
]]--