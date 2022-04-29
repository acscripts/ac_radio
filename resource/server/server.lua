local function hasResource(name)
	return GetResourceState(name):find('start')
end

local framework = (hasResource('es_extended') and 'esx') or (hasResource('qb-core') and 'qb') or (hasResource('ox_core') and 'ox') or ''

-- Create usable items
if not ac.useCommand then
	CreateThread(function()
		if hasResource('ox_inventory') then
			return
		elseif framework == 'esx' then
			local ESX = exports.es_extended:getSharedObject()
			ESX.RegisterUsableItem('radio', function(playerId)
				TriggerClientEvent('ac_radio:openRadio', playerId)
			end)
		elseif framework == 'qb' then
			local QBCore = exports['qb-core']:GetCoreObject()
			QBCore.Functions.CreateUseableItem('radio', function(playerId)
				TriggerClientEvent('ac_radio:openRadio', playerId)
			end)
		end
	end)
end
