---@class GangRankConfig
---@field title string
---@field isLeader? boolean

---@class GangConfig
---@field label string
---@field ranks table<integer, GangRankConfig>

---@type table<string, GangConfig>
Config.Gangs = {
    none = {
        label = 'No Affiliation',
        ranks = {
            [0] = { title = 'None' },
        },
    },
    ballas = {
        label = 'Ballas',
        ranks = {
            [0] = { title = 'Recruit' },
            [1] = { title = 'Soldier' },
            [2] = { title = 'Enforcer' },
            [3] = { title = 'Boss', isLeader = true },
        },
    },
    vagos = {
        label = 'Vagos',
        ranks = {
            [0] = { title = 'Recruit' },
            [1] = { title = 'Soldier' },
            [2] = { title = 'Enforcer' },
            [3] = { title = 'Boss', isLeader = true },
        },
    },
}
