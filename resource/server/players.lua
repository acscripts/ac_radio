---@param source number
local function playerLoaded(source)
	server.voice:setPlayerRadio(source, 0)
end

AddEventHandler('playerDropped', function()
	if server.players[source] then
		server.players[source] = nil
	end
end)

-- es_extended
if server.core == 'esx' then
	AddEventHandler('esx:playerLoaded', function(source, player)
		server.players[source] = { [player.job.name] = player.job.grade }
		playerLoaded(source)
	end)

	AddEventHandler('esx:setJob', function(source, job)
		server.players[source] = { [job.name] = job.grade }
	end)

	for _, player in pairs(server.getPlayers()) do
		server.players[player.source] = { [player.job.name] = player.job.grade }
	end


-- qb-core
elseif server.core == 'qb' then
	AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
		player = player.PlayerData
		server.players[player.source] = { [player.job.name] = player.job.grade.level }
		playerLoaded(player.source)
	end)

	AddEventHandler('QBCore:Server:OnJobUpdate', function(source, job)
		server.players[source] = { [job.name] = job.grade.level }
	end)

	for _, player in pairs(server.getPlayers()) do
		player = player.PlayerData
		server.players[player.source] = { [player.job.name] = player.job.grade.level }
	end


-- ox_core
elseif server.core == 'ox' then
	local ox = exports.ox_core

	AddEventHandler('ox:playerLoaded', function(source)
		server.players[source] = ox:GetPlayer(source).groups
		playerLoaded(source)
	end)

	AddEventHandler('ox:setGroup', function(source, group, rank)
		if server.players[source] then
			server.players[source][group] = rank
		else
			server.players[source] = { [group] = rank }
		end
	end)

	for _, player in pairs(ox:GetPlayers()) do
		server.players[player.source] = ox:GetPlayer(player.source).groups
	end
end
