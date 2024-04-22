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
Config.RepairDuration = 5 --in seconds

Config.Truck = {
    Spawn = vector4(741.47, 127.25, 79.97, 241.81),
    Model = 'boxville',
    Deposit = 250,
}
Config.MaxGroupSize = 4 -- max number of people ina  group that can do the job
Config.MinStops = 2 --Number of stops, will add the size of the group to this amount
Config.MaxStops = 5 --Number of stops, will add the size of the group to this amount
Config.PayMin = 225 --Cash to give per stop
Config.PayMax = 275 --Cash to give per stop

Config.Locations = {
    [1] = {
        coords = vector4(-1278.76, -822.43, 17.10, 217.64),
        repair = {
            vector3(-1263.07, -818.0, 17.1),
            vector3(-1269.62, -809.74, 17.12),
            vector3(-1286.27, -834.56, 17.1),
            vector3(-1274.41, -850.58, 13.12),
            vector3(-1265.39, -856.95, 12.25),
            vector3(-1255.94, -866.95, 12.36),
            vector3(-1287.66, -790.92, 17.6),
            vector3(-1304.91, -803.74, 17.58),
        },
    },
    [2] = {
        coords = vector4(183.93, 299.17, 105.38, 248.11),
        repair = {
            vector3(183.46, 294.16, 105.34),
            vector3(180.05, 293.96, 105.37),
            vector3(185.52, 308.28, 105.39),
            vector3(196.07, 302.04, 105.53),
            vector3(196.93, 298.38, 105.63),
            vector3(202.60, 293.75, 105.61),
            vector3(204.34, 287.81, 105.56),
            vector3(210.27, 290.78, 105.60),
        },
    },
    [3] = {
        coords = vector4(-457.28, 300.14, 83.24, 89.97),
        repair = {
            vector3(-464.42, 297.43, 83.29),
            vector3(-462.93, 288.94, 83.34),
            vector3(-463.57, 282.65, 83.35),
            vector3(-449.71, 288.50, 83.23),
            vector3(-446.98, 288.21, 83.23),
            vector3(-442.93, 287.53, 83.31),
            vector3(-440.01, 297.37, 83.23),
            vector3(-490.53, 299.68, 83.79),
            vector3(-428.50, 293.07, 83.32),
            vector3(-423.79, 285.86, 83.23),
        },
    },
    [4] = {
        coords = vector4(-790.32, -179.38, 37.28, 207.44),
        repair = {
            vector3(-785.12, -177.85, 37.28),
            vector3(-783.60, -177.05, 37.28),
            vector3(-804.27, -186.15, 37.31),
            vector3(-804.21, -190.45, 37.34),
            vector3(-797.70, -171.60, 37.29),
            vector3(-804.45, -169.38, 38.43),
            vector3(-791.34, -201.40, 37.28),
            vector3(-781.13, -203.83, 37.41),
            vector3(-765.79, -218.20, 37.28),
            vector3(-762.66, -223.53, 37.28),
            vector3(-769.03, -224.93, 37.40),
        },
    },
    [5] = {
        coords = vector4(-1154.55, -1551.02, 4.28, 345.68),
        repair = {
            vector3(-1156.35, -1544.30, 4.45),
            vector3(-1163.34, -1551.59, 4.37),
            vector3(-1146.39, -1563.22, 4.42),
            vector3(-1148.50, -1566.35, 4.43),
            vector3(-1155.19, -1571.12, 4.44),
            vector3(-1164.02, -1563.09, 4.39),
            vector3(-1138.43, -1544.56, 4.35),
            vector3(-1135.99, -1550.63, 4.40),
            vector3(-1128.87, -1561.13, 4.38),
        },
    },
    [6] = {
        coords = vector4(-1308.47, -1250.42, 4.50, 26.60),
        repair = {
            vector3(-1325.23, -1254.53, 4.61),
            vector3(-1324.49, -1256.37, 4.61),
            vector3(-1304.14, -1262.33, 4.40),
            vector3(-1300.14, -1269.47, 4.30),
            vector3(-1293.16, -1268.89, 4.09),
            vector3(-1297.57, -1256.97, 4.32),
            vector3(-1314.48, -1242.41, 4.58),
        },
    },
    [7] = {
        coords = vector4(-1267.19, -1111.71, 7.52, 18.07),
        repair = {
            vector3(-1272.10, -1109.99, 7.10),
            vector3(-1270.02, -1114.17, 7.19),
            vector3(-1266.53, -1120.38, 7.41),
            vector3(-1265.93, -1123.04, 7.48),
            vector3(-1262.05, -1125.46, 7.70),
            vector3(-1259.27, -1132.81, 7.71),
            vector3(-1264.55, -1140.20, 7.54),
            vector3(-1254.85, -1146.78, 7.68),
            vector3(-1258.18, -1147.64, 7.58),
            vector3(-1255.09, -1153.49, 7.55),
        },
    },
    [8] = {
        coords = vector4(333.83, -999.02, 29.21, 76.08),
        repair = {
            vector3(327.51, -995.15, 29.30),
            vector3(319.59, -994.89, 29.29),
            vector3(311.25, -1005.27, 29.31),
            vector3(303.33, -1005.20, 29.32),
            vector3(344.17, -994.90, 29.37),
            vector3(345.81, -991.83, 29.35),
            vector3(345.74, -984.14, 29.37),
            vector3(345.82, -967.18, 29.42),
        },
    },
}
Config.PedList = {
    [1] = { 
        model = "s_m_y_garbage", 
        coords = vector3(735.07, 131.07, 79.72),
        minZ = 23.23,
        maxZ = 27.23, 
        heading = 250.75, 
        gender = "male", 
        scenario = "WORLD_HUMAN_CLIPBOARD",
        blipInfo = {
            sprite = 769,
            color = 49,
            scale = 0.7,
            text = "LS WaP",
            enable = true,
        },
    },     
}