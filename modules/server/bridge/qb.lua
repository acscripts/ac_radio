local QB = exports['qb-core']:GetCoreObject()
local Voice = exports['pma-voice']
local Config = require 'config'

AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    Voice:setPlayerRadio(player.PlayerData.source, 0)
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(playerId)
    Voice:setPlayerRadio(playerId, 0)
    Player(playerId).state:set('ac:hasRadioProp', false, true)
end)

CreateThread(function()
    for frequency, allowed in pairs(Config.restrictedChannels) do
        Voice:addChannelCheck(tonumber(frequency), function(playerId)
            local player = QB.Functions.GetPlayer(playerId)
            if not player then return false end

            local job = player.PlayerData.job

            if type(allowed) == 'table' then
                for name, grade in pairs(allowed) do
                    if job.name == name and job.grade >= (grade or 0) then
                        lib.notify(playerId, {
                            type = 'success',
                            description = locale('channel_join', frequency),
                        })
                        return true
                    end
                end
            else
                if job.name == allowed then
                    lib.notify(playerId, {
                        type = 'success',
                        description = locale('channel_join', frequency),
                    })
                    return true
                end
            end

            lib.notify(playerId, {
                type = 'error',
                description = locale('channel_unavailable'),
            })

            return false
        end)
    end
end)
