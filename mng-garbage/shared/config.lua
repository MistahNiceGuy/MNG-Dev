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


Config.Truck = {
    Spawn = vector4(-337.50, -1562.63, 24.95, 71.49),
    Model = 'trash2',
    Deposit = 250,
}
Config.MaxGroupSize = 4 -- max number of people ina  group that can do the job
Config.MinStops = 2 --Number of stops, will add the size of the group to this amount
Config.MaxStops = 5 --Number of stops, will add the size of the group to this amount
Config.MinBags = 2
Config.MaxBags = 6
Config.Payout = 25 -- Amount of Recyclable Materials per stop completed
Config.PayoutItem = 'recyclablematerial'
Config.PayMin = 225 --Cash to give per stop
Config.PayMax = 275 --Cash to give per stop

Config.Locations = {
    -- [1] = {coords = vector4(-348.08, -1571.60, 25.23, 119.39)},
    -- [2] = {coords = vector4(-342.84, -1570.39, 25.23, 302.59),},
     [1] = {coords = vector3(-168.16, -1661.84, 34.84)},
     [2] = {coords = vector3(118.96, -1944.19, 22.04),},
     [3] = {coords = vector3(298.98, -2018.24, 21.69),},
     [4] = {coords = vector3(424.37, -1524.10, 30.59),},
     [5] = {coords = vector3(489.36, -1284.12, 30.70),},
     [6] = {coords = vector3(307.48, -1034.49, 30.58),},
     [7] = {coords = vector3(238.14, -681.67, 38.64),},
     [8] = {coords = vector3(543.52, -203.51, 55.75),},
     [9] = {coords = vector3(268.35, -26.74, 74.90),},
     [10] = {coords = vector3(267.65, 276.79, 106.97),},
     [11] = {coords = vector3(22.65, 375.68, 114.43),},
     [12] = {coords = vector3(-547.93, 286.64, 84.34),},
     [13] = {coords = vector3(-684.18, -169.62, 39.16),},
     [14] = {coords = vector3(-771.88, -218.13, 38.56),},
     [15] = {coords = vector3(-1057.14, -516.32, 37.37),},
     [16] = {coords = vector3(-1559.03, -477.52, 36.79),},
     [17] = {coords = vector3(-1351.24, -894.88, 14.93),},
     [18] = {coords = vector3(-1244.58, -1360.04, 5.42),},
     [19] = {coords = vector3(-845.13, -1112.55, 8.45),},
     [20] = {coords = vector3(-634.61, -1227.08, 13.32),},
     [21] = {coords = vector3(-588.26, -1739.88, 23.96),},
}
Config.PedList = {
    [1] = { 
        model = "s_m_y_garbage", 
        coords = vector3(-349.33, -1569.35, 25.23),
        minZ = 23.23,
        maxZ = 27.23, 
        heading = 310.25, 
        gender = "male", 
        scenario = "WORLD_HUMAN_CLIPBOARD",
        options = {
            {
                type = "server",
                event = "mng-garbage:server:CanStart",
                label = 'Start a Garbage Route',
                icon = 'fa-solid fa-dumpster',
            },
            {
                type = "server",
                event = "mng-garbage:server:EndJob",
                label = 'Finish Work',
                icon = 'fa-solid fa-dumpster',
            },
        },
        blipInfo = {
            sprite = 318,
            color = 5,
            scale = 0.7,
            text = "Garbage Depot",
            enable = true,
        },
    },
    [2] = { 
        model = "s_m_y_garbage", 
        coords = vector3(-355.68, -1555.60, 25.18),
        minZ = 23.18,
        maxZ = 27.18, 
        heading = 175.01, 
        gender = "male", 
        scenario = "WORLD_HUMAN_CLIPBOARD",
        options = {
            {
                type = "client",
                event = "mng-garbage:client:ExchangeMenu",
                label = 'Exchange Recyclable Materials',
                icon = 'fa-solid fa-recycle',
            },
        },
        blipInfo = {
            sprite = 318,
            color = 5,
            scale = 0.7,
            text = "Garbage Depot",
            enable = false,
        },
    }, 
    [3] = { 
        model = "s_m_y_garbage", 
        coords = vector3(59.09, 6475.67, 31.43),
        minZ = 29.43,
        maxZ = 33.43, 
        heading = 225.53, 
        gender = "male", 
        scenario = "WORLD_HUMAN_CLIPBOARD",
        options = {
            {
                type = "client",
                event = "mng-garbage:client:ExchangeMenu",
                label = 'Exchange Recyclable Materials',
                icon = 'fa-solid fa-recycle',
            },
        },
        blipInfo = {
            sprite = 318,
            color = 5,
            scale = 0.7,
            text = "Garbage Depot",
            enable = false,
        },
    },     
}

Config.Ped = {
    model = "s_m_y_garbage", 
    coords = vector4(-350.07, -1569.95, 24.22, 295.97),
    minZ = 23.23,
    maxZ = 27.23, 
    heading = 310.25, 
    gender = "male", 
    scenario = "WORLD_HUMAN_CLIPBOARD",
}