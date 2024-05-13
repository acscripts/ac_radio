fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'ac_radio'
author 'AC Scripts'
version '2.0.1'
description 'A framework-standalone radio UI for FiveM'
repository 'https://github.com/acscripts/ac_radio'


shared_script '@ox_lib/init.lua'
server_script 'resource/server.lua'
client_script 'resource/client.lua'


ui_page 'web/index.html'

files {
  'web/**',
  'config.lua',
  'modules/client/*.lua',
  'locales/*.json',
}


ox_libs {
  'locale',
  'math',
}

dependencies {
  'ox_lib',
  'pma-voice',
}
