if not ac.useCommand then
	CreateThread(function()
		local function hasResource(name)
			return GetResourceState(name):find('start')
		end

		if hasResource('ox_inventory') then
			return
		elseif hasResource('es_extended') then
			local ESX = exports.es_extended:getSharedObject()
			ESX.RegisterUsableItem('radio', function(playerId)
				TriggerClientEvent('ac_radio:openRadio', playerId)
			end)
		elseif hasResource('qb-core') then
			local QBCore = exports['qb-core']:GetCoreObject()
			QBCore.Functions.CreateUseableItem('radio', function(playerId)
				TriggerClientEvent('ac_radio:openRadio', playerId)
			end)
		end
	end)
end


end

