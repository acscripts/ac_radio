fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ac_radio'
author 'ANTOND.#8507'
version '1.0.8'
description 'A framework-standalone radio UI for FiveM'
repository 'https://github.com/antond15/ac_radio'


shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
}

server_scripts {
  '@ox_core/imports/server.lua',
  'resource/server/server.lua',
}

client_scripts {
  'resource/client/utils.lua',
  'resource/client/client.lua'
}

ui_page 'web/index.html'

files {
  'web/**',
  'locales/*.json'
}


dependency 'pma-voice'
