local Voice = exports['pma-voice']

lib.locale()

AddEventHandler('ox:playerLoaded', function(source)
	Voice:setPlayerRadio(source, 0)
end)

for frequency, groups in pairs(ac.restrictedChannels) do
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

if ac.versionCheck then lib.versionCheck('acscripts/ac_radio') end

SetConvarReplicated('radio_noRadioDisconnect', tostring(ac.noRadioDisconnect))
SetConvarReplicated('voice_useNativeAudio', tostring(ac.radioEffect))
SetConvarReplicated('voice_enableSubmix', ac.radioEffect and '1' or '0')
SetConvarReplicated('voice_enableRadioAnim', ac.radioAnimation and '1' or '0')
SetConvarReplicated('voice_defaultRadio', ac.radioKey)
