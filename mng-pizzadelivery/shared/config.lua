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
Config.PedList = {
    [1] = { 
        model = "s_m_y_chef_01", 
        coords = vector3(538.14, 101.57, 95.53),
        minZ = 94.53,
        maxZ = 98.53, 
        heading = 153.99, 
        gender = "male", 
        scenario = "PROP_HUMAN_STAND_IMPATIENT",
        options = {
            {
                type = "client",
                event = "mng-pizzadelivery:client:PizzaMenu",
                label = 'View Work Menu',
                icon = 'fa-solid fa-pizza-slice',
            },
        },
        blipInfo = {
            sprite = 267,
            color = 17,
            scale = 0.7,
            text = "Pizza Delivery",
            enable = true,
        },
    },
}

Config.ExperiencePerLevel = 100 -- Exp needed to level
Config.MinExpGain = 3 --Minimum Exp gained per individual delivery. The amount gained will be randomized between the min and max values.
Config.MaxExpGain = 5 --Maximum Exp gained per individual delivery. The amount gained will be randomized between the min and max values.
Config.EnableJobFinishExp = true -- Enable/Disable giving additional exp on completing a full delivery route.
Config.JobFinishExpGain = 5 -- Exp gained for finishing an entire delivery job
Config.MinPayout = 250 --Minimum payout gained per individual delivery. The amount gained will be randomized between the min and max values.
Config.MaxPayout = 350 --Maximum payout gained per individual delivery. The amount gained will be randomized between the min and max values.
Config.LevelPayoutIncrease = 0.10 -- Increase delivery payout by a percentage per level. Default 0.01 will increase payout by one percent per level. Set to 0 if you want to disable to bonus.

Config.VehicleSpawn = {
    Coords = vector4(533.99, 89.05, 95.91, 70.74),
}

Config.Vehicles = {
    Scooter = {Model = 'faggio', RequiredLevel = 0, MinDeliveries = 2, MaxDeliveries = 5,},
    Motorcycle = {Model = 'vader', RequiredLevel = 5, MinDeliveries = 3, MaxDeliveries = 7,},
    Car = {Model = 'raiden', RequiredLevel = 10, MinDeliveries = 5, MaxDeliveries = 10,},
}

Config.DeliveryZones = {
    -- [1] = vector4(530.48, 97.48, 96.29, 68.28), used for testing
    -- [2] = vector4(542.38, 92.37, 96.37, 253.72),used for testing
    [1] = vector4(-305.08, 431.04, 110.48, 191.49),
    [2] = vector4(346.28, 440.53, 147.9, 118.04),
    [3] = vector4(-112.96, 985.97, 235.75, 289.66),
    [4] = vector4(-1215.69, 458.14, 92.06, 182.58),
    [5] = vector4(-1667.69, -441.21, 40.36, 52.62),
    [6] = vector4(-1452.51, -653.36, 29.58, 311.09),
    [7] = vector4(-1777.07, -701.51, 10.52, 317.88),
    [8] = vector4(-1161.15, -1099.89, 2.22, 208.81),
    [9] = vector4(-978.12, -1108.32, 2.15, 212.28),
    [10] = vector4(-699.14, -1032.22, 16.43, 303.78),
    [11] = vector4(-192.23, -1559.76, 34.95, 141.16),
    [12] = vector4(257.55, -1723.01, 29.65, 324.88),
    [13] = vector4(399.32, -1865.02, 26.72, 136.17),
    [14] = vector4(305.1, -2086.63, 17.71, 112.56),
    [15] = vector4(758.85, -816.15, 26.29, 89.87),
    [16] = vector4(886.96, -608.05, 58.45, 140.05),
    [17] = vector4(1100.86, -411.27, 67.56, 265.67),
    [18] = vector4(880.2, -205.42, 71.98, 334.49),
    [19] = vector4(1386.24, -593.46, 74.49, 228.46),
    -- [20] = vector4(341.56, 2615.1, 44.67, 208.89), removed for long range, will adjust rewards based on distance
    -- [21] = vector4(1142.32, 2654.62, 38.15, 278.09),
    -- [22] = vector4(1826.85, 3729.59, 33.96, 34.91),
    -- [23] = vector4(1880.45, 3920.64, 33.21, 282.77),
    -- [24] = vector4(2355.96, 2564.36, 47.09, 211.92),
    -- [25] = vector4(1535.66, 2232.01, 77.7, 269.91),
}

Config.SpecialDelivery = {
    [1] = vector4(-1062.60, -1663.27, 4.56, 294.05),
}

Config.SpecialDeliveryChance = 0 --percent chance to get special delivery
Config.CoolDownTime = 60 --Time in seconds to prevent new job if they end early.