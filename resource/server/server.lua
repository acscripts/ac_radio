local config = require 'config'
local Voice = exports['pma-voice']

lib.locale()

AddEventHandler('ox:playerLoaded', function(source)
	Voice:setPlayerRadio(source, 0)
end)

for frequency, groups in pairs(config.restrictedChannels) do
	Voice:addChannelCheck(frequency, function(source)
		local player = Ox.GetPlayer(source)
		if not player then return false end

		if player.hasGroup(groups) then
			lib.notify(source, {
				type = 'success',
				description = locale('channel_join', frequency)
			})
			return true
		else
			lib.notify(source, {
				type = 'error',
				description = locale('channel_unavailable')
			})
			return false
		end
	end)
end

if config.versionCheck then lib.versionCheck('acscripts/ac_radio') end

SetConvarReplicated('radio_noRadioDisconnect', tostring(config.noRadioDisconnect))
SetConvarReplicated('voice_useNativeAudio', tostring(config.radioEffect))
SetConvarReplicated('voice_enableSubmix', config.radioEffect and '1' or '0')
SetConvarReplicated('voice_enableRadioAnim', config.radioAnimation and '1' or '0')
SetConvarReplicated('voice_defaultRadio', config.radioKey)
