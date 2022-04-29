local function hasResource(name)
	return GetResourceState(name):find('start')
end

server = {
	framework = (hasResource('es_extended') and 'esx') or (hasResource('qb-core') and 'qb') or (hasResource('ox_core') and 'ox') or ''
}

-- Create usable items
if not ac.useCommand then
	CreateThread(function()
		if hasResource('ox_inventory') then
			return -- Stop when using ox_inventory as it should be registered manually (see docs/ox.md)
		elseif server.framework == 'esx' then
			local ESX = exports.es_extended:getSharedObject()
			ESX.RegisterUsableItem('radio', function(playerId)
				TriggerClientEvent('ac_radio:openRadio', playerId)
			end)
		elseif server.framework == 'qb' then
			local QBCore = exports['qb-core']:GetCoreObject()
			QBCore.Functions.CreateUseableItem('radio', function(playerId)
				TriggerClientEvent('ac_radio:openRadio', playerId)
			end)
		end
	end)
end

-- Group check yoinked from https://github.com/overextended/ox_inventory/blob/3112665275a10815a610a5cbd382518e7efe55e8/modules/bridge/server.lua#L1
for frequency, allowed in pairs(ac.restrictedChannels) do
	exports['pma-voice']:addChannelCheck(frequency, function(source)
		local groups = server.players[source]
		if not groups then return false end

		if type(allowed) == 'table' then
			for name, rank in pairs(allowed) do
				local groupRank = groups[name]
				if groupRank and groupRank >= (rank or 0) then
					return true
				end
			end
		else
			if groups[allowed] then
				return true
			end
		end

		return false
    end)
end
