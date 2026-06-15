lib.addCommand('setjob', {
    help = "Set a character's occupation",
    params = {
        { name = 'target', type = 'playerId', help = 'Server ID' },
        { name = 'job', type = 'string', help = 'Job id' },
        { name = 'rank', type = 'number', help = 'Rank (default 0)', optional = true },
    },
    restricted = Config.AdminGroup,
}, function(source, args)
    local character = Core.Characters[args.target]
    if not character then
        return Core.Notify(source, 'Character not loaded.', 'error')
    end

    if character:setOccupation(args.job, args.rank or 0) then
        Core.Notify(source, ('Set %s to %s (%d).'):format(character.displayName, args.job, args.rank or 0), 'success')
        Core.Notify(character.source, ('Your occupation is now %s - %s.'):format(character.occupation.label, character.occupation.title), 'inform')
    else
        Core.Notify(source, 'Invalid job or rank.', 'error')
    end
end)

lib.addCommand('setgang', {
    help = "Set a character's affiliation",
    params = {
        { name = 'target', type = 'playerId', help = 'Server ID' },
        { name = 'gang', type = 'string', help = 'Gang id' },
        { name = 'rank', type = 'number', help = 'Rank (default 0)', optional = true },
    },
    restricted = Config.AdminGroup,
}, function(source, args)
    local character = Core.Characters[args.target]
    if not character then
        return Core.Notify(source, 'Character not loaded.', 'error')
    end

    if character:setAffiliation(args.gang, args.rank or 0) then
        Core.Notify(source, ('Set %s to %s (%d).'):format(character.displayName, args.gang, args.rank or 0), 'success')
        Core.Notify(character.source, ('Your affiliation is now %s - %s.'):format(character.affiliation.label, character.affiliation.title), 'inform')
    else
        Core.Notify(source, 'Invalid gang or rank.', 'error')
    end
end)

lib.addCommand('setstateid', {
    help = "Change a character's StateID (UID)",
    params = {
        { name = 'target', type = 'playerId', help = 'Server ID' },
        { name = 'stateid', type = 'number', help = 'New StateID' },
    },
    restricted = Config.AdminGroup,
}, function(source, args)
    local ok, reason = Core.SetStateId(args.target, args.stateid)
    if ok then
        Core.Notify(source, ('StateID updated to %d.'):format(args.stateid), 'success')
        Core.Notify(args.target, ('Your StateID is now %d.'):format(args.stateid), 'inform')
    else
        local messages = {
            taken = 'That StateID is already in use.',
            no_character = 'Character not loaded.',
            invalid = 'Invalid StateID.',
        }
        Core.Notify(source, messages[reason] or 'Failed to update StateID.', 'error')
    end
end)

lib.addCommand('givemoney', {
    help = 'Give money to a character',
    params = {
        { name = 'target', type = 'playerId', help = 'Server ID' },
        { name = 'account', type = 'string', help = 'cash or bank' },
        { name = 'amount', type = 'number', help = 'Amount' },
    },
    restricted = Config.AdminGroup,
}, function(source, args)
    local character = Core.Characters[args.target]
    if not character then
        return Core.Notify(source, 'Character not loaded.', 'error')
    end

    if character:addBalance(args.account, args.amount) then
        character:save()
        Core.Notify(source, ('Gave $%s (%s) to %s.'):format(args.amount, args.account, character.displayName), 'success')
    else
        Core.Notify(source, 'Invalid account or amount.', 'error')
    end
end)

lib.addCommand('stateid', {
    help = 'Show your own StateID',
}, function(source)
    local character = Core.Characters[source]
    if character then
        Core.Notify(source, ('Your StateID is %s%d.'):format(Config.StateId.Prefix, character.stateId), 'inform')
    end
end)
