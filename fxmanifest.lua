fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ac_radio'
author 'ANTOND.#8507'
version '1.2.0'
description 'A framework-standalone radio UI for FiveM'
repository 'https://github.com/antond15/ac_radio'


shared_scripts {
  'config.lua',
  'resource/locales.lua'
}

server_scripts {
  'resource/server/server.lua',
  'resource/server/players.lua',
  'resource/server/version.lua'
}

client_scripts {
  'resource/client/utils.lua',
  'resource/client/client.lua'
}

ui_page 'web/index.html'

files {
  'web/**',
  'locales/*.lua'
}


dependency 'pma-voice'
