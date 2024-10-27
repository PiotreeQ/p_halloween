fx_version 'cerulean'
game 'gta5'
author 'piotreq [discord.gg/piotreqscripts] [tebex.pscripts.store]'
description 'Halloween Leaderboard'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'modules/client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'modules/server/main.lua',
}

ui_page 'web/index.html'

files {
    'bridge/*.lua',
    'config.lua',
    'web/index.html',
    'web/style.css',
    'web/app.js',
    'web/img/*.png'
}