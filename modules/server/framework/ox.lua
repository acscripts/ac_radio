if not lib.checkDependency('ox_core', '1.5.7', true) then return end

local Ox <const> = require '@ox_core.lib.init' --[[ @as OxServer ]]
local Voice <const> = exports['pma-voice']
local Config <const> = require 'config'

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
            if not player?.charId then return false end

            local isAllowed = player.getGroup(allowed) ~= nil

            lib.notify(playerId, {
                type = isAllowed and 'success' or 'error',
                description = isAllowed and locale('channel_join', frequency + 0.0) or locale('channel_unavailable'),
            })

            return isAllowed
        end)
    end
end)
