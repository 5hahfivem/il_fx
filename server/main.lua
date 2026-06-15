---@class Core
---@field Characters table<integer, Character>
---@field NextStateId integer
---@field Ready boolean
Core = {
    Characters = {},
    NextStateId = Config.StateId.StartsAt,
    Ready = false,
}

local function ensureSchema()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `characters` (
            `state_id` INT UNSIGNED NOT NULL,
            `license` VARCHAR(60) NOT NULL,
            `display_name` VARCHAR(60) DEFAULT NULL,
            `identity` LONGTEXT DEFAULT NULL,
            `accounts` LONGTEXT DEFAULT NULL,
            `occupation` LONGTEXT DEFAULT NULL,
            `affiliation` LONGTEXT DEFAULT NULL,
            `metadata` LONGTEXT DEFAULT NULL,
            `last_position` LONGTEXT DEFAULT NULL,
            PRIMARY KEY (`state_id`),
            UNIQUE KEY `license` (`license`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `core_sequences` (
            `id` VARCHAR(50) NOT NULL,
            `value` INT UNSIGNED NOT NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end

local function loadSequence()
    local stored = MySQL.scalar.await('SELECT value FROM core_sequences WHERE id = ?', { 'stateId' })
    if stored then
        Core.NextStateId = stored
        return
    end

    local highest = MySQL.scalar.await('SELECT MAX(state_id) FROM characters')
    local start = Config.StateId.StartsAt
    if highest and highest >= start then
        start = highest + 1
    end

    Core.NextStateId = start
    MySQL.insert.await('INSERT INTO core_sequences (id, value) VALUES (?, ?)', { 'stateId', start })
end

---@return integer
function Core.GenerateStateId()
    local stateId = Core.NextStateId
    Core.NextStateId = stateId + 1
    MySQL.update('UPDATE core_sequences SET value = ? WHERE id = ?', { Core.NextStateId, 'stateId' })
    return stateId
end

---@param source integer
---@return Character?
function Core.GetCharacter(source)
    return Core.Characters[source]
end

---@param stateId integer
---@return Character?
function Core.GetCharacterByStateId(stateId)
    stateId = tonumber(stateId)
    for _, character in pairs(Core.Characters) do
        if character.stateId == stateId then
            return character
        end
    end
end

---@return Character[]
function Core.GetCharacters()
    local list = {}
    for _, character in pairs(Core.Characters) do
        list[#list + 1] = character
    end
    return list
end

---@param source integer
---@param message string
---@param kind? 'inform'|'success'|'error'|'warning'
function Core.Notify(source, message, kind)
    TriggerClientEvent('ox_lib:notify', source, {
        description = message,
        type = kind or 'inform',
    })
end

CreateThread(function()
    ensureSchema()
    loadSequence()
    Core.Ready = true
    print(('[il_fx] ready — next StateID is %d'):format(Core.NextStateId))
end)
