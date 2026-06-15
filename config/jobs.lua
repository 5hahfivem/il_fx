---@class RankConfig
---@field title string
---@field salary? integer
---@field isLeader? boolean

---@class JobConfig
---@field label string
---@field category? string
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
        ranks = {
            [0] = { title = 'Apprentice', salary = 40 },
            [1] = { title = 'Mechanic', salary = 60 },
            [2] = { title = 'Manager', salary = 90, isLeader = true },
        },
    },
}
