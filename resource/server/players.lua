server.players = {}

AddEventHandler('playerDropped', function()
	if server.players[source] then
		server.players[source] = nil
	end
end)

local function onLoaded(source)
	exports['pma-voice']:setPlayerRadio(source, 0)
end

-- es_extended
if server.framework == 'esx' then
	AddEventHandler('esx:playerLoaded', function(source, xPlayer)
		onLoaded(source)
		server.players[source] = { [xPlayer.job.name] = xPlayer.job.grade }
	end)

	AddEventHandler('esx:setJob', function(source, job)
		server.players[source] = { [job.name] = job.grade }
	end)

-- qb-core
elseif server.framework == 'qb' then
	AddEventHandler('QBCore:Server:PlayerLoaded', function(qbPlayer)
		onLoaded(source)
		local job = qbPlayer.PlayerData.job
		server.players[qbPlayer.PlayerData.source] = { [job.name] = job.grade.level }
	end)

	AddEventHandler('QBCore:Server:OnJobUpdate', function(source, job)
		server.players[source] = { [job.name] = job.grade.level }
	end)

-- ox_core
elseif server.framework == 'ox' then
	AddEventHandler('ox:playerLoaded', function(source)
		onLoaded(source)
		server.players[source] = exports.ox_core:CPlayer('getGroups', source)
	end)

	AddEventHandler('ox_groups:setGroup', function(source, group, rank)
		local groups = server.players[source]
		if groups then
			groups[group] = rank
		else
			server.players[source] = { [group] = rank }
		end
	end)
end
