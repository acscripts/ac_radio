---@param name string
---@return boolean
local function hasResource(name)
	return GetResourceState(name):find('start') ~= nil
end

server = {
	core = (hasResource('es_extended') and 'esx') or (hasResource('qb-core') and 'qb') or (hasResource('ox_core') and 'ox') or '',
	voice = exports['pma-voice'],
	players = {}
}



if server.core == 'esx' then
	local ESX = exports.es_extended:getSharedObject()
	server.getPlayers = ESX.GetExtendedPlayers

	if not ac.useCommand and not hasResource('ox_inventory') then
		ESX.RegisterUsableItem('radio', function(source)
			TriggerClientEvent('ac_radio:openRadio', source)
		end)

		if ac.noRadioDisconnect then
			AddEventHandler('esx:onRemoveInventoryItem', function(source, name, count)
				if name == 'radio' and count < 1 then
					TriggerClientEvent('ac_radio:disableRadio', source)
					server.voice:setPlayerRadio(source, 0)
				end
			end)
		end
	end

elseif server.core == 'qb' then
	local QB = exports['qb-core']:GetCoreObject()
	server.getPlayers = QB.Functions.GetQBPlayers

	if not ac.useCommand and not hasResource('ox_inventory') then
		QB.Functions.CreateUseableItem('radio', function(source)
			TriggerClientEvent('ac_radio:openRadio', source)
		end)
	end
end



-- Group check yoinked from https://github.com/overextended/ox_inventory/blob/3112665275a10815a610a5cbd382518e7efe55e8/modules/bridge/server.lua#L1
for frequency, allowed in pairs(ac.restrictedChannels) do
	server.voice:addChannelCheck(tonumber(frequency), function(source)
		local groups = server.players[source]
		if not groups then
			TriggerClientEvent('ac_radio:notify', source, 'error', locale('channel_unavailable'))
			return false
		end

		if type(allowed) == 'table' then
			for name, rank in pairs(allowed) do
				local groupRank = groups[name]
				if groupRank and groupRank >= (rank or 0) then
					TriggerClientEvent('ac_radio:notify', source, 'success', locale('channel_join', frequency))
					return true
				end
			end
		else
			if groups[allowed] then
				TriggerClientEvent('ac_radio:notify', source, 'success', locale('channel_join', frequency))
				return true
			end
		end

		TriggerClientEvent('ac_radio:notify', source, 'error', locale('channel_unavailable'))
		return false
	end)
end



SetConvarReplicated('radio_noRadioDisconnect', tostring(ac.noRadioDisconnect))
SetConvarReplicated('voice_useNativeAudio', tostring(ac.radioEffect))
SetConvarReplicated('voice_enableSubmix', ac.radioEffect and '1' or '0')
SetConvarReplicated('voice_enableRadioAnim', ac.radioAnimation and '1' or '0')
SetConvarReplicated('voice_defaultRadio', ac.radioKey)
