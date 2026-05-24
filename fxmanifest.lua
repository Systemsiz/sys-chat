fx_version 'cerulean'
game 'gta5'

author 'Antigravity'
description 'Modern, QBCore Compatible Chat Script'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

lua54 'yes'
