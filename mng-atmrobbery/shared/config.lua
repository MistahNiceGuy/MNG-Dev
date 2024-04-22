Config = {}

Config.ATMModels = {
    `prop_atm_01`,
    `prop_atm_02`,
    `prop_atm_03`,
    `prop_fleeca_atm`,
}

Config.BruteForceTime = 1.5 -- time in minutes
Config.DDOSDelay = 2.5 -- time in minutes
Config.KeyLoggerTime = 120 -- time in minutes
Config.CodeInjectorDelay = 2.5 -- time in minutes
Config.ATMAttemps = 3 -- number of times a hack can be failed before the ATM goes into security mode and can no longer be hacked.
Config.LockDownTime = 5 -- Time in minutes to lockdown atm and prevent collectin cash after successful hack.
Config.MinPayout = 500 -- Minimum cash to give on payout
Config.MaxPayout = 1000 -- Maximum cash to give on payout. Will randomize between min and max.
Config.CodeInjectorModifier = 2 -- multiplies payout for using Code Injector
Config.PayoutItem = 'cash' --item in string to give for payout
