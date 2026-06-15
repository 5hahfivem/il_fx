---@param jobId string
---@return JobConfig?
exports('GetJob', function(jobId)
    return Config.Jobs[jobId]
end)

---@return table<string, JobConfig>
exports('GetJobs', function()
    return Config.Jobs
end)

---@param gangId string
---@return GangConfig?
exports('GetGang', function(gangId)
    return Config.Gangs[gangId]
end)

---@return table<string, GangConfig>
exports('GetGangs', function()
    return Config.Gangs
end)
