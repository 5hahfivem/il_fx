Config = {}

Config.Defaults = {
    occupation = 'unemployed',
    affiliation = 'none',
}

Config.StartingAccounts = {
    cash = 500,
    bank = 5000,
}

Config.Accounts = { 'cash', 'bank' }

Config.SpawnPosition = vec4(-1035.71, -2731.87, 12.86, 0.0)

Config.Camera = {
    coords = vec3(-682.0, -1092.0, 226.0),
    rotation = vec3(0.0, 0.0, -45.0),
}

Config.SaveInterval = 10

Config.StateId = {
    StartsAt = 1000,
    Prefix = '',
}

Config.Nationalities = {
    { value = 'american', label = 'American' },
    { value = 'mexican', label = 'Mexican' },
    { value = 'canadian', label = 'Canadian' },
    { value = 'british', label = 'British' },
    { value = 'german', label = 'German' },
    { value = 'other', label = 'Other' },
}

Config.Paycheck = {
    Schedule = '*/15 * * * *',
    Account = 'bank',
    UBI = 100,
    CollectDistance = 3.0,
    Ped = {
        model = `s_m_m_security_01`,
        coords = vec4(441.13, -979.27, 30.69, 90.0),
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        blip = {
            enabled = true,
            sprite = 524,
            color = 2,
            scale = 0.8,
            label = 'Paycheck',
        },
    },
}

Config.AdminGroup = 'group.admin'
