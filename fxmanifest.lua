fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'il_fx'
author '5hahfivem'
description 'Lightweight FiveM core — characters, occupations, affiliations, StateID, paychecks'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
    'config/jobs.lua',
    'config/gangs.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/character.lua',
    'server/security.lua',
    'server/paycheck.lua',
    'server/commands.lua',
    'server/exports.lua',
    'server/compat_qbx.lua',
}

client_scripts {
    'client/main.lua',
    'client/paycheck.lua',
    'client/compat_qbx.lua',
}

dependencies {
    'ox_lib',
    'oxmysql',
}
