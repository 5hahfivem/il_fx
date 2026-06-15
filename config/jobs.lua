---@class RankConfig
---@field title string
---@field salary? integer
---@field isLeader? boolean

---@class JobLocation
---@field type? string
---@field pos? vector3
---@field dist? number

---@class JobConfig
---@field label string
---@field category? string
---@field business? boolean
---@field hasGarage? boolean
---@field locations? vector3[]|JobLocation[]
---@field ranks table<integer, RankConfig>

---@type table<string, JobConfig>
Config.Jobs = {
    unemployed = {
        label = 'Civilian',
        category = 'civilian',
        ranks = {
            [0] = { title = 'Unemployed', salary = 0 },
        },
    },
    police = {
        label = 'Police',
        category = 'lawEnforcement',
        ranks = {
            [0] = { title = 'Cadet', salary = 50 },
            [1] = { title = 'Officer', salary = 75 },
            [2] = { title = 'Sergeant', salary = 100 },
            [3] = { title = 'Lieutenant', salary = 125 },
            [4] = { title = 'Chief', salary = 175, isLeader = true },
        },
    },
    ambulance = {
        label = 'EMS',
        category = 'medical',
        ranks = {
            [0] = { title = 'Trainee', salary = 50 },
            [1] = { title = 'Paramedic', salary = 80 },
            [2] = { title = 'Doctor', salary = 110 },
            [3] = { title = 'Chief', salary = 160, isLeader = true },
        },
    },
    mechanic = {
        label = 'Mechanic',
        category = 'civilian',
        business = true,
        hasGarage = true,
        locations = {
            vec3(-337.18, -136.7, 39.0),
            vec3(-211.84, -1325.61, 30.89),
        },
        ranks = {
            [0] = { title = 'Apprentice', salary = 40 },
            [1] = { title = 'Mechanic', salary = 60 },
            [2] = { title = 'Manager', salary = 90, isLeader = true },
        },
    },
    cardealer = {
        label = 'Premium Deluxe Motorsport',
        category = 'civilian',
        business = true,
        hasGarage = true,
        locations = {
            { type = 'car', pos = vec3(-56.7, -1096.6, 26.4), dist = 20 },
            { type = 'aircraft', pos = vec3(-1652.5, -3140.0, 14.0), dist = 10 },
        },
        ranks = {
            [0] = { title = 'Salesperson', salary = 0 },
            [1] = { title = 'Owner', salary = 250, isLeader = true },
        },
    },
}
