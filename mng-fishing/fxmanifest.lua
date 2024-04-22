fx_version 'cerulean'
game 'gta5'

description 'Fishing Tied into Economic Stock Levels'
author 'MistahNiceGuy'

client_scripts {
    '@PolyZone/client.lua',
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

shared_scripts {
    'shared/*.lua',
    '@ox_lib/init.lua',
}

lua54 'yes'
