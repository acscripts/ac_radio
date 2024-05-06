local Config = require 'config'

SetConvarReplicated('radio_noRadioDisconnect', tostring(Config.noRadioDisconnect))
SetConvarReplicated('voice_useNativeAudio', tostring(Config.radioEffect))
SetConvarReplicated('voice_enableSubmix', Config.radioEffect and '1' or '0')
SetConvarReplicated('voice_enableRadioAnim', Config.radioAnimation and '1' or '0')
SetConvarReplicated('voice_defaultRadio', Config.radioTalkKey)

lib.versionCheck('acscripts/ac_radio')



local function hasExport(export)
    local resource, exportName = string.strsplit('.', export)

    return pcall(function()
        return exports[resource][exportName]
    end)
end

SetTimeout(0, function()
    if hasExport('ox_core.GetPlayer') then
        require 'modules.server.bridge.ox'
    elseif hasExport('es_extended.getSharedObject') then
        require 'modules.server.bridge.esx'
    elseif hasExport('qb-core.GetCoreObject') then
        require 'modules.server.bridge.qb'
    end
end)
