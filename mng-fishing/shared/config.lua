Config = {}
Config = {
	Blips = true,
	BlipNamer = true,
	Pedspawn = true,
	Invincible = true,
	Frozen = true,
	Stoic = true,
	Fade = true,
	Distance = 40.0,
}
Config.Pedspawn = true
Config.MinusOne = true
--Don't touch above lines.

Config.Debug = false -- true/false to enable debug. Mainly to show polyzones. Uses heavy resources while debug is enabled due to the large zones.
Config.CancelKey = 200 -- Key used to cancel fishing. Default is Escape. Find Control ID at https://docs.fivem.net/docs/game-references/controls/#controls
Config.MinBiteTime = 2 -- Minumum time in seconds it takes to get a bite.
Config.MaxBiteTime = 4 -- Maximum time in seconds it take to get a bite. Each cast will take a random amount between these two values.
Config.BiteNotifyTime = 3 -- Time in seconds to notify they have a bite before the skillcheck appears.
Config.PerfectBonus = 2 -- Extra Exp awarded if hitting a perfect skill bar.
Config.FishingRod = 'fishingrod'
Config.FreshWaterBait = 'freshbait' -- Item name for freshwater bait being used. Must be a string.
Config.SaltWaterBait = 'saltbait' -- Item name for saltwater bait being used. Must be a string.
Config.Lure = 'lure' -- Item name for lure being used. Must be a string.
Config.ConsumeLure = false -- Enable or Disable consuming a lure on catch. Defaul is false. Idea is the lure is a permanent bait type rewarded for those who hit max level.
Config.LureLevel = 20 -- Level needed to purchase a lure
Config.NightStart = 19 -- Time in 24 hour format you want people to start being able to catch night fish.
Config.NightEnd = 6 -- Time in 24 hour format you want people to stop being able to catch night fish.
Config.ExpPerLevel = 200 --Amount of exp needed per level
Config.ExpMin = 200 -- Minumum amount of exp you can get per catch
Config.ExpMax = 200 -- Maximum amount of exp you can get per catch
Config.MaxLevel = 20 -- Maximum level a player can achieve. This is also the max amount of skillpoints they will receive.
Config.EnableFishValuePerLevel = true --If enabled, increase the sell price of fish per overall fishing level.
Config.SkillTimeReduction = 2 -- Amount of bite time to reduce per level of angler skill. Value in seconds.
Config.FishValuePerLevel = 0.05 -- If enabled, increase the sell price of fish per overall fishing level. Percent in decimal form. 0.05 is a 5% increase per level. At level 20 it would increase sell price by 100%
Config.RareChancePerLevel = 1.0 -- Increase chance to catch rare fish per luck skill level. Percent in decimal form. 1.0 is a 1% increased chance per level. If RareChance = 10 then next level will make the chance 11, then 12, then 13 etc...
Config.RareChance = 10 -- Base percent chance to get a rare fish

Config.PedList = {
    [1] = { 
        name = 'Joseph Gate',
        tag = 'Fishing Guide',
        model = "mp_m_exarmy_01", 
        coords = vector3(-1733.94, -1122.95, 12.02),
        minZ = 11.02,
        maxZ = 15.02, 
        heading = 330.08, 
        gender = "male", 
        scenario = "PROP_HUMAN_STAND_IMPATIENT",
        options = {
            {
                type = "client",
                event = "mng-fishing:client:FishMenu", -- Don't touch this event
                label = 'View Fishing Menu',
                icon = 'fa-solid fa-fish',
            },
        },
        blipInfo = {
            sprite = 68,
            color = 3,
            scale = 0.7,
            text = "Fishing Guide",
            enable = true,
        },
    },
    [2] = { 
        name = 'Tyler Mercer',
        tag = 'Fishing Guide',
        model = "mp_m_exarmy_01", 
        coords = vector3(-1612.04, 5262.08, 2.97),
        minZ = 1.97,
        maxZ = 5.97, 
        heading = 205.06, 
        gender = "male", 
        scenario = "PROP_HUMAN_STAND_IMPATIENT",
        options = {
            {
                type = "client",
                event = "mng-fishing:client:FishMenu", -- Don't touch this event
                label = 'View Fishing Menu',
                icon = 'fa-solid fa-fish',
            },
        },
        blipInfo = {
            sprite = 68,
            color = 3,
            scale = 0.7,
            text = "Fishing Guide",
            enable = true,
        },
    },
    [3] = { 
        name = 'Bruce Carroll',
        tag = 'Fishing Guide',
        model = "mp_m_exarmy_01", 
        coords = vector3(1302.77, 4226.36, 32.91),
        minZ = 31.91,
        maxZ = 35.91, 
        heading = 72.65, 
        gender = "male", 
        scenario = "PROP_HUMAN_STAND_IMPATIENT",
        options = {
            {
                type = "client",
                event = "mng-fishing:client:FishMenu", -- Don't touch this event
                label = 'View Fishing Menu',
                icon = 'fa-solid fa-fish',
            },
        },
        blipInfo = {
            sprite = 68,
            color = 3,
            scale = 0.7,
            text = "Fishing Guide",
            enable = true,
        },
    },
}
Config.Fish = {
    ['freshwater'] = { --[[ table of all fish that can be caught in fresh water. Each condition will add to the loot pool.
     So if you fish at night while it is raining with a lure your availble loot pool would inlcude all 247, night, rain, and lure fish--]]
        ['247'] = { -- can be caught at any time of the day or night
            'crappie',
            'smallmouthbass',
            'yellowperch',
        },
        ['day'] = { -- can only be caught during the day time
            'largemouthbass',
            'redearsunfish',
            'rainbowtrout',
        },
        ['night'] = { -- can only be caught during the night time
            'bluegill',
            'channelcatfish',
            'walleye',
        },
        ['rain'] = { -- can only be caught while it is raining
            'northernpike',
            'bullheadcatfish',
            'stripedbass',
        },
        ['lure'] = { -- can only be caught while using a lure. Other fish types can be caught while using a lure but these will be added to the loot pool if using a lure and not bait.
            'alligatorgar',
            'carp',
            'snook',
        },
    },
    ['saltwater'] = {
        ['247'] = {
            'yellowtang',
            'stingray',
            'blackmarlin',
            'wahoo',
        },
        ['day'] = {
            'salmon',
            'mahimahi',
            'barracuda',
        },
        ['night'] = {
            'bluemarlin',
            'tarpon',
            'makoshark',
        },
        ['rain'] = {
            'stripedmarlin',
            'swordfish',
            'stingray',
        },
        ['lure'] = {
            'sailfish',
            'halibut',
            'amberjack',
        },
    },
    ['rare'] = { -- if they get lucky enough to get rare fish then the loot pool would only include rare fish
        'eel',
        'americanpaddlefish',
        'peppermintangelfish',
        'bluefintuna',
        'musekellunge',
    }
}
Config.FishPrices = { -- set individual price of each type of fish here.
    ['alligatorgar'] = 175, --fresh lure
    ['amberjack'] = 125, -- salt lure
    ['americanpaddlefish'] = 200, --rare
    ['barracuda'] = 100, --salt day
    ['blackmarlin'] = 85, --salt 247
    ['bluefintuna'] = 210, --rare
    ['bluegill'] = 100, --fresh night
    ['bluemarlin'] = 100, --salt night
    ['bullheadcatfish'] = 105, --fresh rain
    ['channelcatfish'] = 115, -- fresh night
    ['carp'] = 125, -- fresh lure
    ['crappie'] = 85, -- fresh 247
    ['eel'] = 245, --rare
    ['halibut'] = 145, -- salt lure
    ['largemouthbass'] = 100, -- fresh day
    ['mahimahi'] = 100, -- salt day
    ['makoshark'] = 125, -- salt night
    ['musekellunge'] = 275, -- rare
    ['northernpike'] = 120, -- fresh rain
    ['peppermintangelfish'] = 250, -- rare
    ['rainbowtrout'] = 95, -- fresh day
    ['redearsunfish'] = 90, -- fresh day
    ['sailfish'] = 175, -- salt lure
    ['salmon'] = 100, -- salt day
    ['smallmouthbass'] = 85, -- fresh 247
    ['snook'] = 145, -- fresh lure
    ['stingray'] = 105, -- salt rain
    ['stripedbass'] = 145, --fresh rain
    ['stripedmarlin'] = 120, -- salt rain
    ['swordfish'] = 145, -- salt rain
    ['tarpon'] = 115, -- salt night
    ['wahoo'] = 85, -- salt 247
    ['walleye'] = 125, -- fresh night
    ['yellowperch'] = 95, -- fresh 247
    ['yellowtang'] = 85, -- salt 247
    ['fishingbait'] = 2 -- old fishing bait
}

Config.ShopPrices = { -- set individual price of each type of fish here.
    ['fishingrod'] = 150,
    ['freshbait'] = 5,
    ['saltbait'] = 5,
    ['lure'] = 500,
}