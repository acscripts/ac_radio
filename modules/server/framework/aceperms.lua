local Voice = exports['pma-voice']
local Config = require 'config'

Citizen.CreateThread(function()
    for frequency, allowed in pairs(Config.restrictedChannels) do
        Voice:addChannelCheck(tonumber(frequency), function(playerId)
            if type(allowed) == 'table' then
                for _, ace in pairs(allowed) do
                    if IsPlayerAceAllowed(playerId, ace) then
                        lib.notify(playerId, {
                            type = 'success',
                            description = locale('channel_join', frequency + 0.0),
                        })
                        return true
                    end
                end
            else
                if IsPlayerAceAllowed(playerId, allowed) then
                    lib.notify(playerId, {
                        type = 'success',
                        description = locale('channel_join', frequency + 0.0),
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
