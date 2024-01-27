fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ac_radio'
author 'ANTOND.#8507'
version '1.2.0'
description 'A framework-standalone radio UI for FiveM'
repository 'https://github.com/antond15/ac_radio'


shared_scripts {
  '@ox_lib/init.lua',
}

server_scripts {
  '@ox_core/imports/server.lua',
  'resource/server/server.lua',
}

client_scripts {
  'resource/client/client.lua',
}

ui_page 'web/index.html'

files {
  'web/**',
  'locales/*.json',
  'config.lua',
  'resource/client/utils.lua',
}


dependency 'pma-voice'
