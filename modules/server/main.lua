local Config <const> = require 'config'
local Utils <const> = require 'modules.server.utils'

lib.versionCheck('acscripts/ac_radio')

SetConvarReplicated('radio:disconnectWithoutRadio', tostring(Config.disconnectWithoutRadio))
SetConvarReplicated('radio_noRadioDisconnect', tostring(Config.disconnectWithoutRadio)) -- backwards compatibility

SetConvarReplicated('voice_useNativeAudio', tostring(Config.radioEffect))
SetConvarReplicated('voice_enableSubmix', Config.radioEffect and '1' or '0')
SetConvarReplicated('voice_enableRadioAnim', Config.radioAnimation and '1' or '0')
SetConvarReplicated('voice_defaultRadio', Config.radioTalkKey)

SetTimeout(0, function()
    if Utils.hasExport('ox_core.GetPlayer') then
        require 'modules.server.framework.ox'
    elseif Utils.hasExport('es_extended.getSharedObject') then
        require 'modules.server.framework.esx'
    elseif Utils.hasExport('qb-core.GetCoreObject') then
        require 'modules.server.framework.qb'
    end
end)

---@param state boolean
RegisterNetEvent('ac_radio:setRadioProp', function(state)
    local playerId = source

    if type(state) ~= 'boolean' then return end

    Player(playerId).state:set('ac:hasRadioProp', state, true)
end)
