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
    Spawn = vector4(-411.72, -2792.26, 5.90, 314),
    Model = 'boxville4',
    Deposit = 250,
}
Config.MaxGroupSize = 4 --Max Number of people for this job in a group
Config.MinStops = 3 --Number of stops for groups
Config.MaxStops = 7 --Number of stops for groups
Config.MinBoxes = 5
Config.MaxBoxes = 10
Config.PayMin = 1700 --Cash to give per stop
Config.PayMax = 2000 --Cash to give per stop

Config.Locations = {
     [1] = {coords = vec3(-3047.66, 589.95, 7.78)},
     [2] = {coords = vec3(-3248.14, 1007.48, 12.83),},
     [3] = {coords = vec3(1741.36, 6419.54, 35.04),},
     [4] = {coords = vec3(1710.38, 4930.08, 42.22),},
     [5] = {coords = vec3(1963.67, 3749.69, 32.26),},
     [6] = {coords = vec3(2670.88, 3286.30, 55.39),},
     [7] = {coords = vec3(542.16, 2663.73, 42.36),},
     [8] = {coords = vec3(2553.14, 399.39, 108.61),},
     [9] = {coords = vec3(372.88, 341.16, 103.33),},
     [10] = {coords = vec3(1130.19, -989.26, 45.97),},
     [11] = {coords = vec3(-1468.17, -386.96, 38.81),},
}
Config.PedList = {
    [1] = { 
        model = "s_m_m_ups_02", 
        coords = vector3(-424.33, -2789.82, 5.53),
        minZ = 3.53,
        maxZ = 7.53, 
        heading = 315.90, 
        gender = "male", 
        scenario = "WORLD_HUMAN_CLIPBOARD",
        blipInfo = {
            sprite = 478,
            color = 56,
            scale = 0.7,
            text = "Post Op",
            enable = true,
        },
    },
}