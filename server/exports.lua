---@return Core
exports('GetCore', function()
    return Core
end)

---@param source integer
---@return Character?
exports('GetCharacter', function(source)
    return Core.Characters[source]
end)

---@param stateId integer
---@return Character?
exports('GetCharacterByStateId', function(stateId)
    return Core.GetCharacterByStateId(stateId)
end)

---@return Character[]
exports('GetCharacters', function()
    return Core.GetCharacters()
end)

---@param source integer
---@return integer?
exports('GetStateId', function(source)
    local character = Core.Characters[source]
    return character and character.stateId
end)

---@param source integer
---@param stateId integer
---@return boolean ok, string? reason
exports('SetStateId', function(source, stateId)
    return Core.SetStateId(source, stateId)
end)

---@param source integer
---@return Occupation?
exports('GetOccupation', function(source)
    local character = Core.Characters[source]
    return character and character.occupation
end)

---@param source integer
---@param jobId string
---@param rank? integer
---@return boolean
exports('SetOccupation', function(source, jobId, rank)
    local character = Core.Characters[source]
    if not character then return false end
    return character:setOccupation(jobId, rank)
end)

---@param source integer
---@return Affiliation?
exports('GetAffiliation', function(source)
    local character = Core.Characters[source]
    return character and character.affiliation
end)

---@param source integer
---@param gangId string
---@param rank? integer
---@return boolean
exports('SetAffiliation', function(source, gangId, rank)
    local character = Core.Characters[source]
    if not character then return false end
    return character:setAffiliation(gangId, rank)
end)

---@param source integer
---@param account string
---@return integer
exports('GetBalance', function(source, account)
    local character = Core.Characters[source]
    return character and character:getBalance(account) or 0
end)

---@param source integer
---@param account string
---@param amount integer
---@return boolean
exports('AddBalance', function(source, account, amount)
    local character = Core.Characters[source]
    if not character then return false end
    local ok = character:addBalance(account, amount)
    if ok then character:save() end
    return ok
end)

---@param source integer
---@param account string
---@param amount integer
---@return boolean
exports('RemoveBalance', function(source, account, amount)
    local character = Core.Characters[source]
    if not character then return false end
    local ok = character:removeBalance(account, amount)
    if ok then character:save() end
    return ok
end)

---@param source integer
---@param key? string
---@return any
exports('GetMetadata', function(source, key)
    local character = Core.Characters[source]
    return character and character:getMeta(key)
end)

---@param source integer
---@param key string
---@param value any
---@return boolean
exports('SetMetadata', function(source, key, value)
    local character = Core.Characters[source]
    if not character then return false end
    character:setMeta(key, value)
    return true
end)

---@return table<string, JobConfig>
exports('GetJobs', function()
    return Config.Jobs
end)

---@return table<string, GangConfig>
exports('GetGangs', function()
    return Config.Gangs
end)
