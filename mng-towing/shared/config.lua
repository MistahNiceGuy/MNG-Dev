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
    Spawn = vector4(408.86, -1638.16, 29.29, 230.27),
    Model = 'flatbed',
    Deposit = 250,
}
Config.MaxGroupSize = 2 -- max number of people ina  group that can do the job
Config.PayMin = 600 --Cash to give per stop
Config.PayMax = 900 --Cash to give per stop
Config.MinStops = 4
Config.MaxStops = 10

Config.MechJobs = {
    'mechanic',
    'mechanic1',
    'mechanic2',
}

Config.Target = { --Target Vehicle Spawn Locations
    [1] = {coords = vector4(-227.69, -1392.51, 31.26, 94.68)},
    [2] = {coords = vector4(-243.87, -1660.36, 33.54, 359.95)},
    [3] = {coords = vector4(90.07, -1965.97, 20.75, 321.39)},
    [4] = {coords = vector4(285.60, -1990.93, 20.51, 228.26)},
    [5] = {coords = vector4(328.78, -2042.93, 20.77, 318.09)},
    [6] = {coords = vector4(528.24, -1752.95, 28.99, 148.28)},
    [7] = {coords = vector4(353.98, -1697.57, 37.79, 319.51)},
    [8] = {coords = vector4(-83.72, -1405.67, 29.32, 271.47)},
    [9] = {coords = vector4(-1468.63, -651.25, 29.50, 34.41)},
    [10] = {coords = vector4(869.50, -1547.66, 30.32, 184.30)},
    [12] = {coords = vector4(850.92, -1840.40, 29.08, 84.53)},
    [13] = {coords = vector4(1074.79, -1949.84, 31.01, 145.80)},
    [14] = {coords = vector4(1001.92, -2336.45, 30.51, 174.85)},
    [15] = {coords = vector4(1066.18, -2468.70, 28.74, 1.85)},
    [16] = {coords = vector4(987.38, -2550.07, 28.30, 354.88)},
    [17] = {coords = vector4(1443.89, -2598.24, 48.24, 348.20)},
    [18] = {coords = vector4(1302.03, -1707.94, 55.08, 45.76)},
    [19] = {coords = vector4(1228.83, -1606.48, 51.68, 39.00)}, 
    [20] = {coords = vector4(1209.65, -1230.56, 35.23, 269.66)},
    [21] = {coords = vector4(746.37, -966.49, 24.67, 86.94)},
    [22] = {coords = vector4(749.00, -1187.71, 24.28, 359.22)},
    [23] = {coords = vector4(709.57, -1395.58, 26.34, 103.50)},
    [24] = {coords = vector4(462.73, -606.06, 28.50, 31.54)},
    [25] = {coords = vector4(294.90, -693.63, 29.30, 253.72)},
    [26] = {coords = vector4(40.99, -702.01, 44.08, 159.79)},
    [27] = {coords = vector4(-40.69, -713.94, 32.86, 157.85)},
    [28] = {coords = vector4(-341.32, -754.59, 53.25, 91.25)},
    [29] = {coords = vector4(-447.05, -767.51, 30.56, 267.39)},
    [30] = {coords = vector4(-576.34, -1029.57, 22.18, 92.45)},
    [31] = {coords = vector4(-753.78, -1037.76, 12.80, 120.64)},
    [32] = {coords = vector4(-646.88, -1211.03, 11.37, 122.75)},
    [33] = {coords = vector4(-1035.68, -1335.65, 5.44, 255.47)},
    [34] = {coords = vector4(-1008.79, -1466.74, 5.00, 214.69)},
    [35] = {coords = vector4(-966.18, -1592.26, 5.02, 193.62)},
    [36] = {coords = vector4(-1180.08, -1486.05, 4.38, 122.67)},
    [37] = {coords = vector4(-1276.44, -1356.87, 4.30, 109.67)},
    [38] = {coords = vector4(-1276.27, -1151.97, 6.30, 294.46)},
    [39] = {coords = vector4(-1626.66, -890.77, 9.06, 136.53)},
    [40] = {coords = vector4(-1740.74, -722.05, 10.46, 48.95)},
    [41] = {coords = vector4(-1771.89, -519.45, 38.81, 120.63)},
    [42] = {coords = vector4(-1991.06, -301.02, 48.11, 54.54)},
    [43] = {coords = vector4(-2158.29, -393.26, 13.34, 79.85)},
    [44] = {coords = vector4(-2975.18, 80.29, 11.47, 145.52)},
    [45] = {coords = vector4(-3040.45, 151.94, 11.61, 297.50)},
    [46] = {coords = vector4(-1651.94, -253.59, 54.73, 157.50)},
    [47] = {coords = vector4(-1487.06, -202.03, 50.40, 221.30)},
    [48] = {coords = vector4(-1451.54, -368.41, 43.50, 184.45)},
    [49] = {coords = vector4(-1541.29, -564.06, 33.66, 35.98)},
}
Config.PedList = {
    [1] = { 
        model = "ig_floyd", 
        coords = vector3(409.13, -1622.80, 29.29),
        minZ = 27.23,
        maxZ = 31.23,  
        heading = 228.65, 
        gender = "male", 
        scenario = "WORLD_HUMAN_CLIPBOARD",
        options = {
            {
                type = "server",
                event = "mng-towing:server:CanStart",
                label = 'Start Towing',
                icon = 'fa-solid fa-truck-pickup',
            },
            {
                type = "server",
                event = "mng-towing:server:EndJob",
                label = 'Finish Work',
                icon = 'fa-solid fa-truck-pickup',
            },
        },
        blipInfo = {
            sprite = 68,
            color = 2,
            scale = 0.7,
            text = "Tow Depot",
            enable = true,
        },
    },
}

Config.Depot = vector4(401.98, -1632.38, 29.29, 50.0)

Config.Models = {
    [1] = "ninef",
    [2] = "ninef2",
    [3] = "banshee",
    [4] = "alpha",
    [5] = "baller",
    [6] = "bison",
    [7] = "huntley",
    [8] = "serrano",
    [9] = "asea",
    [10] = "pigalle",
    [11] = "bullet",
    [12] = "turismor",
    [13] = "zentorno",
    [14] = "dominator",
    [15] = "blade",
    [16] = "chino",
    [17] = "sabregt",
    [18] = "bati",
    [19] = "carbonrs",
    [20] = "akuma",
    [21] = "thrust",
    [22] = "exemplar",
    [23] = "felon",
    [24] = "sentinel",
    [25] = "blista",
    [26] = "fusilade",
    [27] = "jackal",
    [28] = "blista2",
    [29] = "rocoto",
    [30] = "seminole",
    [31] = "landstalker",
    [32] = "picador",
    [33] = "prairie",
    [34] = "stanier",
    [35] = "gauntlet",
    [36] = "virgo",
    [37] = "tailgater",
    [38] = "jester",
    [39] = "rhapsody",
    [40] = "feltzer2",
    [41] = "buffalo",
    [42] = "buffalo2",
    [43] = "washington",
    [44] = "cognoscenti",
    [45] = "ruiner",
    [46] = "rebel",
    [48] = "slamvan",
    [58] = "zion",
    [59] = "zion2",
    [60] = "tampa",
    [61] = "sultan",
    [62] = "asbo",
    [63] = "panto",
    [64] = "oracle",
    [65] = "oracle2",
    [66] = "sentinel2",
    [67] = "baller2",
    [68] = "schafter2",
    [69] = "schwarzer",
    [70] = "cavalcade",
    [71] = "cavalcade2",
    [72] = "comet2",

}

Config.Ped = {
    model = "ig_floyd", 
    coords = vector4(407.31, -1625.11, 28.29, 228.87),
    minZ = 27.23,
    maxZ = 31.23,  
    heading = 228.65, 
    gender = "male", 
    scenario = "WORLD_HUMAN_CLIPBOARD",
}