fx_version 'cerulean'
game 'gta5'

author 'The Illusion Squid'
version '1.0.0'
description 'Skydiving script'
-- shared_scripts {
-- }


client_scripts {
	'@menuv/menuv.lua',
    'client/main.lua',
	'client/menu.lua',
	'client/interactions.lua',
	'config.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server/main.lua',
	'config.lua'
}

ui_page {
	'html/ui.html'
}

files {
	'html/ui.html',
	'html/css/main.css',
	'html/js/app.js',
	'html/fonts/*.ttf',
}

dependency 'menuv'