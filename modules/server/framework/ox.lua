if not lib.checkDependency('ox_core', '0.25.0', true) then return end

local Ox = require '@ox_core.lib.init' --[[ @as OxServer ]]
local Voice = exports['pma-voice']
local Config = require 'config'

AddEventHandler('ox:playerLoaded', function(playerId)
    Voice:setPlayerRadio(playerId, 0)
end)

AddEventHandler('ox:playerLogout', function(playerId)
    Voice:setPlayerRadio(playerId, 0)
    Player(playerId).state:set('ac:hasRadioProp', false, true)
end)

CreateThread(function()
    for frequency, allowed in pairs(Config.restrictedChannels) do
        Voice:addChannelCheck(tonumber(frequency), function(playerId)
            local player = Ox.GetPlayer(playerId)
            if not player or not player.charId then return false end

            local isAllowed = player.getGroup(allowed) ~= nil

            if isAllowed then
                lib.notify(playerId, {
                    type = 'success',
                    description = locale('channel_join', frequency + 0.0),
                })
            else
                lib.notify(playerId, {
                    type = 'error',
                    description = locale('channel_unavailable'),
                })
            end
        end)
    end
end)
