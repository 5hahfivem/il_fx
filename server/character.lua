local encode = json.encode
local decode = json.decode

local validAccount = {}
for _, name in ipairs(Config.Accounts) do
    validAccount[name] = true
end

local validNationality = {}
for _, option in ipairs(Config.Nationalities) do
    validNationality[option.value] = true
end

---@class Identity
---@field firstName string
---@field lastName string
---@field gender? string
---@field dateOfBirth? integer|string
---@field nationality? string

---@class Occupation
---@field id string
---@field label string
---@field category? string
---@field rank integer
---@field title string
---@field salary integer
---@field isLeader boolean

---@class Affiliation
---@field id string
---@field label string
---@field rank integer
---@field title string
---@field isLeader boolean

---@class CharacterRecord
---@field stateId integer
---@field license string
---@field displayName string
---@field identity Identity
---@field accounts table<string, integer>
---@field occupation Occupation
---@field affiliation Affiliation
---@field metadata table<string, any>
---@field lastPosition vector4

---@param value any
---@return string?
local function sanitizeName(value)
    if type(value) ~= 'string' then return nil end
    value = value:gsub('[%z\1-\31]', ''):gsub('^%s+', ''):gsub('%s+$', '')
    if value == '' then return nil end

    local length = utf8.len(value)
    if not length then return nil end

    if length > 24 then
        value = value:sub(1, utf8.offset(value, 25) - 1)
    end

    return value
end

---@param id string
---@param rank integer
---@return Occupation
local function resolveOccupation(id, rank)
    local job = Config.Jobs[id]
    if not job then
        id = Config.Defaults.occupation
        job = Config.Jobs[id]
        rank = 0
    end
    local def = job.ranks[rank] or job.ranks[0]
    return {
        id = id,
        label = job.label,
        category = job.category,
        rank = job.ranks[rank] and rank or 0,
        title = def.title,
        salary = def.salary or 0,
        isLeader = def.isLeader or false,
    }
end

---@param id string
---@param rank integer
---@return Affiliation
local function resolveAffiliation(id, rank)
    local gang = Config.Gangs[id]
    if not gang then
        id = Config.Defaults.affiliation
        gang = Config.Gangs[id]
        rank = 0
    end
    local def = gang.ranks[rank] or gang.ranks[0]
    return {
        id = id,
        label = gang.label,
        rank = gang.ranks[rank] and rank or 0,
        title = def.title,
        isLeader = def.isLeader or false,
    }
end

local function defaultPosition()
    local pos = Config.SpawnPosition
    return { x = pos.x, y = pos.y, z = pos.z, w = pos.w }
end

---@class Character : OxClass
---@field source integer
---@field stateId integer
---@field license string
---@field displayName string
---@field identity Identity
---@field accounts table<string, integer>
---@field occupation Occupation
---@field affiliation Affiliation
---@field metadata table<string, any>
---@field lastPosition vector4
local Character = lib.class('Character')

---@param source integer
---@param record CharacterRecord
function Character:constructor(source, record)
    self.source = source
    self.stateId = record.stateId
    self.license = record.license
    self.displayName = record.displayName
    self.identity = record.identity
    self.accounts = record.accounts
    self.occupation = record.occupation
    self.affiliation = record.affiliation
    self.metadata = record.metadata
    self.lastPosition = record.lastPosition
end

function Character:syncState()
    local state = Player(self.source).state
    state:set('stateId', self.stateId, true)
    state:set('occupation', self.occupation, true)
    state:set('affiliation', self.affiliation, true)
    state:set('displayName', self.displayName, true)
end

---@param account string
---@return integer
function Character:getBalance(account)
    return self.accounts[account] or 0
end

---@param account string
---@param amount integer
---@return boolean
function Character:addBalance(account, amount)
    if not validAccount[account] then return false end
    amount = tonumber(amount)
    if not amount or amount <= 0 then return false end
    amount = math.floor(amount)
    self.accounts[account] = (self.accounts[account] or 0) + amount
    return true
end

---@param account string
---@param amount integer
---@return boolean
function Character:removeBalance(account, amount)
    if not validAccount[account] then return false end
    amount = tonumber(amount)
    if not amount or amount <= 0 then return false end
    amount = math.floor(amount)
    local balance = self.accounts[account] or 0
    if balance < amount then return false end
    self.accounts[account] = balance - amount
    return true
end

---@param jobId string
---@param rank? integer
---@return boolean
function Character:setOccupation(jobId, rank)
    local job = Config.Jobs[jobId]
    rank = tonumber(rank) or 0
    if not job or not job.ranks[rank] then return false end

    self.occupation = resolveOccupation(jobId, rank)
    Player(self.source).state:set('occupation', self.occupation, true)
    self:save()
    TriggerEvent('core:server:occupationChanged', self.source, self.occupation)
    return true
end

---@param gangId string
---@param rank? integer
---@return boolean
function Character:setAffiliation(gangId, rank)
    local gang = Config.Gangs[gangId]
    rank = tonumber(rank) or 0
    if not gang or not gang.ranks[rank] then return false end

    self.affiliation = resolveAffiliation(gangId, rank)
    Player(self.source).state:set('affiliation', self.affiliation, true)
    self:save()
    TriggerEvent('core:server:affiliationChanged', self.source, self.affiliation)
    return true
end

---@param key? string
---@return any
function Character:getMeta(key)
    if key == nil then return self.metadata end
    return self.metadata[key]
end

---@param key string
---@param value any
---@return any
function Character:setMeta(key, value)
    self.metadata[key] = value
    return value
end

---@return table
function Character:toExport()
    return {
        source = self.source,
        stateId = self.stateId,
        displayName = self.displayName,
        identity = self.identity,
        accounts = self.accounts,
        occupation = self.occupation,
        affiliation = self.affiliation,
        metadata = self.metadata,
        lastPosition = self.lastPosition,
    }
end

function Character:capturePosition()
    local ped = GetPlayerPed(self.source)
    if not ped or ped == 0 then return end

    local coords = GetEntityCoords(ped)
    if coords.x == 0.0 and coords.y == 0.0 then return end

    self.lastPosition = { x = coords.x, y = coords.y, z = coords.z, w = GetEntityHeading(ped) }
end

---@param awaitQuery? boolean
function Character:save(awaitQuery)
    local query = 'UPDATE characters SET display_name = ?, identity = ?, accounts = ?, occupation = ?, affiliation = ?, metadata = ?, last_position = ? WHERE state_id = ?'
    local params = {
        self.displayName,
        encode(self.identity),
        encode(self.accounts),
        encode(self.occupation),
        encode(self.affiliation),
        encode(self.metadata),
        encode(self.lastPosition),
        self.stateId,
    }

    if awaitQuery then
        MySQL.update.await(query, params)
    else
        MySQL.update(query, params)
    end
end

---@param character Character
---@return Character
local function register(character)
    Core.Characters[character.source] = character
    character:syncState()
    return character
end

---@param source integer
---@param row table
---@return Character
local function fromRow(source, row)
    local occupation = row.occupation and decode(row.occupation)
    local affiliation = row.affiliation and decode(row.affiliation)
    local metadata = row.metadata and decode(row.metadata) or {}
    if metadata.pendingPaycheck == nil then
        metadata.pendingPaycheck = 0
    end

    ---@type CharacterRecord
    local record = {
        stateId = row.state_id,
        license = row.license,
        displayName = row.display_name,
        identity = row.identity and decode(row.identity) or { firstName = row.display_name, lastName = '' },
        accounts = row.accounts and decode(row.accounts) or { cash = 0, bank = 0 },
        occupation = resolveOccupation(occupation and occupation.id or Config.Defaults.occupation, occupation and occupation.rank or 0),
        affiliation = resolveAffiliation(affiliation and affiliation.id or Config.Defaults.affiliation, affiliation and affiliation.rank or 0),
        metadata = metadata,
        lastPosition = row.last_position and decode(row.last_position) or defaultPosition(),
    }

    return Character:new(source, record)
end

---Validate identity input and insert a new character row. Does not load it.
---@param source integer
---@param license string
---@param input table
---@return CharacterRecord?
function Core.InsertCharacter(source, license, input)
    local firstName = sanitizeName(input and input.firstName)
    local lastName = sanitizeName(input and input.lastName)
    if not firstName or not lastName then return nil end

    local gender = (input.gender == 'female' or input.gender == 'male') and input.gender or 'male'
    local nationality = validNationality[input.nationality] and input.nationality or Config.Nationalities[1].value
    local dateOfBirth = input.dateOfBirth
    if type(dateOfBirth) ~= 'number' and type(dateOfBirth) ~= 'string' then
        dateOfBirth = 0
    end

    ---@type CharacterRecord
    local record = {
        stateId = Core.GenerateStateId(),
        license = license,
        displayName = ('%s %s'):format(firstName, lastName),
        identity = { firstName = firstName, lastName = lastName, gender = gender, dateOfBirth = dateOfBirth, nationality = nationality },
        accounts = { cash = Config.StartingAccounts.cash, bank = Config.StartingAccounts.bank },
        occupation = resolveOccupation(Config.Defaults.occupation, 0),
        affiliation = resolveAffiliation(Config.Defaults.affiliation, 0),
        metadata = { pendingPaycheck = 0 },
        lastPosition = defaultPosition(),
    }

    MySQL.insert.await(
        'INSERT INTO characters (state_id, license, display_name, identity, accounts, occupation, affiliation, metadata, last_position) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        {
            record.stateId, record.license, record.displayName,
            encode(record.identity), encode(record.accounts),
            encode(record.occupation), encode(record.affiliation),
            encode(record.metadata), encode(record.lastPosition),
        }
    )

    return record
end

---@param source integer
---@param license string
---@return Character?
function Core.CreateCharacter(source, license)
    local input = lib.callback.await('core:requestIdentity', source)
    local record = Core.InsertCharacter(source, license, input)

    if not record then
        DropPlayer(source, 'il_fx: character details were invalid.')
        return nil
    end

    return register(Character:new(source, record))
end

---@param source integer
---@param row table
---@return Character
function Core.LoadCharacter(source, row)
    return register(fromRow(source, row))
end

---@param source integer
---@param newId integer
---@return boolean ok, string? reason
function Core.SetStateId(source, newId)
    local character = Core.Characters[source]
    if not character then return false, 'no_character' end

    newId = tonumber(newId)
    if not newId or newId < 0 or newId ~= math.floor(newId) then return false, 'invalid' end
    if newId == character.stateId then return true end

    local taken = MySQL.scalar.await('SELECT 1 FROM characters WHERE state_id = ?', { newId })
    if taken then return false, 'taken' end

    local previous = character.stateId
    MySQL.update.await('UPDATE characters SET state_id = ? WHERE state_id = ?', { newId, previous })
    character.stateId = newId
    Player(source).state:set('stateId', newId, true)

    if newId >= Core.NextStateId then
        Core.NextStateId = newId + 1
        MySQL.update('UPDATE core_sequences SET value = ? WHERE id = ?', { Core.NextStateId, 'stateId' })
    end

    return true
end

---@param awaitQuery? boolean
function Core.SaveAll(awaitQuery)
    for _, character in pairs(Core.Characters) do
        character:capturePosition()
        character:save(awaitQuery)
    end
end

local loading = {}
local resendCooldown = {}

RegisterNetEvent('core:server:characterReady', function()
    local source = source
    local existing = Core.Characters[source]
    if existing then
        local now = GetGameTimer()
        if resendCooldown[source] and now - resendCooldown[source] < 1000 then return end
        resendCooldown[source] = now
        TriggerClientEvent('core:client:characterLoaded', source, existing:toExport())
        return
    end

    if loading[source] or not Core.Ready then return end
    loading[source] = true

    local license = GetPlayerIdentifierByType(source, 'license')
    if not license then
        loading[source] = nil
        DropPlayer(source, 'il_fx: no valid license identifier found.')
        return
    end

    local row = MySQL.single.await('SELECT * FROM characters WHERE license = ?', { license })

    if not GetPlayerEndpoint(source) then
        loading[source] = nil
        return
    end

    local character = row and Core.LoadCharacter(source, row) or Core.CreateCharacter(source, license)
    loading[source] = nil
    if not character then return end

    TriggerClientEvent('core:client:characterLoaded', source, character:toExport())
    TriggerEvent('core:server:characterLoaded', source)
    print(('[il_fx] %s loaded (StateID %d)'):format(GetPlayerName(source), character.stateId))
end)

AddEventHandler('playerDropped', function()
    local source = source
    loading[source] = nil
    resendCooldown[source] = nil

    local character = Core.Characters[source]
    if not character then return end
    character:capturePosition()
    character:save()
    Core.Characters[source] = nil
end)

CreateThread(function()
    local interval = Config.SaveInterval * 60000
    while true do
        Wait(interval)
        Core.SaveAll()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Core.SaveAll(true)
end)
