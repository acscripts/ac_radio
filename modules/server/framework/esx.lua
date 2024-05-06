local Config = require 'config'
local Utils = require 'modules.server.utils'
local ESX = exports.es_extended:getSharedObject()
local Voice = exports['pma-voice']

AddEventHandler('esx:playerLoaded', function(playerId)
    Voice:setPlayerRadio(playerId, 0)
end)

AddEventHandler('esx:playerLogout', function(playerId)
    Voice:setPlayerRadio(playerId, 0)
    Player(playerId).state:set('ac:hasRadioProp', false, true)
end)

CreateThread(function()
    if Config.useUsableItem and not Utils.hasExport('ox_inventory.Items') then
        ESX.RegisterUsableItem('radio', function(playerId)
            TriggerClientEvent('ac_radio:openRadio', playerId)
        end)

        if Config.disconnectWithoutRadio then
            AddEventHandler('esx:onRemoveInventoryItem', function(playerId, name, count)
                if name == 'radio' and count < 1 then
                    TriggerClientEvent('ac_radio:disableRadio', playerId)
                    Voice:setPlayerRadio(playerId, 0)
                end
            end)
        end
    end

    for frequency, allowed in pairs(Config.restrictedChannels) do
        Voice:addChannelCheck(tonumber(frequency), function(playerId)
            local player = ESX.GetPlayerFromId(playerId)
            if not player then return false end

            local job = player.getJob()

            if type(allowed) == 'table' then
                for name, grade in pairs(allowed) do
                    if job.name == name and job.grade >= (grade or 0) then
                        lib.notify(playerId, {
                            type = 'success',
                            description = locale('channel_join', frequency + 0.0),
                        })
                        return true
                    end
                end
            else
                if job.name == allowed then
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
