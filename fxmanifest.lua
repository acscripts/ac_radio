fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ANTOND.#8507'
description 'FiveM radio for pma-voice'
version '1.0.0'


server_script 'resource/server.lua'

client_scripts {
  'config.lua',
  'resource/utils.lua',
  'resource/client.lua'
}


ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/script.js',
  'html/assets/technology.ttf',
  'html/assets/radio.png'
}
