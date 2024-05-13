local Voice = exports['pma-voice']
local Config = require 'config'
local frequencyStep = 1
local thisUserIsUnableToReadDocumentation = false

local isOpened = false
local requestedFrequency = nil
local lastVolume = nil



CreateThread(function()
    local step = tostring(Config.frequencyStep)
    local pos = step:find('%.')
    frequencyStep = pos and #step:sub(pos + 1) or 0

    -- Check if server has correct version of pma-voice because certain users are special and can't read documentation.
    -- This is the only way because the is no version variable in pma-voice and the latest release is too outdated.
    local volume = Voice:getRadioVolume()
    if volume > 0 and volume < 1 then
        thisUserIsUnableToReadDocumentation = true
    end
end)

---@return number
local function getRadioVolume()
    local volume = Voice:getRadioVolume()
    return thisUserIsUnableToReadDocumentation and volume * 100 or volume
end



local function openRadio()
    if isOpened then return end
    isOpened = true

    TriggerEvent('ox_inventory:disarm', true)

    LocalPlayer.state:set('ac:hasRadioProp', true, true)

    local animDict = cache.vehicle and 'cellphone@in_car@ds' or 'cellphone@'
    lib.playAnim(cache.ped, animDict, 'cellphone_text_in', 4.0, 4.0, -1, 50)

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
    SetCursorLocation(0.917, 0.873)
    SendNUIMessage({ action = 'openUi' })

    while isOpened do
        DisableAllControlActions(0)
        EnableControlAction(0, 21, true) -- INPUT_SPRINT
        EnableControlAction(0, 22, true) -- INPUT_JUMP
        EnableControlAction(0, 30, true) -- INPUT_MOVE_LR
        EnableControlAction(0, 31, true) -- INPUT_MOVE_UD
        EnableControlAction(0, 59, true) -- INPUT_VEH_MOVE_LR
        EnableControlAction(0, 71, true) -- INPUT_VEH_ACCELERATE
        EnableControlAction(0, 72, true) -- INPUT_VEH_BRAKE
        Wait(0)
    end

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    StopAnimTask(cache.ped, animDict, 'cellphone_text_in', 1.0)
    Wait(100)
    lib.playAnim(cache.ped, animDict, 'cellphone_text_out', 4.0, 4.0, -1, 50)
    Wait(200)
    StopAnimTask(cache.ped, animDict, 'cellphone_text_out', 1.0)

    LocalPlayer.state:set('ac:hasRadioProp', false, true)
end



---@param frequency number
---@return number
local function roundFrequency(frequency)
    local mult = 10 ^ frequencyStep
    return math.floor(frequency * mult + 0.5) / mult
end

---@param frequency number
---@return false | number
local function joinFrequency(frequency)
    frequency = roundFrequency(frequency)

    if frequency > 0 and frequency <= Config.maximumFrequencies then
        Voice:setVoiceProperty('radioEnabled', true)
        Voice:setRadioChannel(frequency)

        if not Config.restrictedChannels[frequency] then
            lib.notify({
                type = 'success',
                description = locale('channel_join', frequency),
            })
        end

        return frequency
    end

    lib.notify({
        type = 'error',
        description = locale('channel_unavailable'),
    })

    return false
end

local function leaveFrequency()
    Voice:removePlayerFromRadio()
    Voice:setVoiceProperty('radioEnabled', false)
end

local function closeUi()
    isOpened = false
    requestedFrequency = nil
end



RegisterNUICallback('closeUi', function(_, cb)
    cb(1)
    closeUi()
end)

---@param frequency number
---@param cb fun(frequency: false | number)
RegisterNUICallback('joinFrequency', function(frequency, cb)
    local result = joinFrequency(frequency)
    cb(result)
end)

RegisterNUICallback('leaveFrequency', function(_, cb)
    cb(1)

    leaveFrequency()

    lib.notify({
        type = 'success',
        description = locale('channel_disconnect'),
    })
end)

RegisterNUICallback('volumeUp', function(_, cb)
    cb(1)

    local currentVolume = lastVolume or getRadioVolume()

    if lastVolume then
        lastVolume = nil
        lib.notify({
            type = 'info',
            description = locale('volume_unmute'),
            duration = 1000,
        })
    end

    if currentVolume >= 100 then
        return lib.notify({
            type = 'error',
            description = locale('volume_max'),
            duration = 2500,
        })
    end

    local volume = math.clamp(currentVolume + Config.volumeStep, Config.volumeStep, 100)

    Voice:setRadioVolume(volume)

    lib.notify({
        type = 'info',
        description = locale('volume_up', math.floor(volume)),
        duration = 1500,
        icon = 'volume-high',
    })
end)

RegisterNUICallback('volumeDown', function(_, cb)
    cb(1)

    local currentVolume = lastVolume or getRadioVolume()

    if lastVolume then
        lastVolume = nil
        lib.notify({
            type = 'info',
            description = locale('volume_unmute'),
            duration = 1000,
        })
    end

    if currentVolume <= Config.volumeStep then
        return lib.notify({
            type = 'error',
            description = locale('volume_min'),
            duration = 2500,
        })
    end

    local volume = math.clamp(currentVolume - Config.volumeStep, Config.volumeStep, 100)

    Voice:setRadioVolume(volume)

    lib.notify({
        type = 'info',
        description = locale('volume_down', math.floor(volume)),
        duration = 1500,
        icon = 'volume-low',
    })
end)

RegisterNUICallback('volumeMute', function(_, cb)
    cb(1)

    if lastVolume then
        Voice:setRadioVolume(lastVolume)
        lastVolume = nil

        lib.notify({
            type = 'success',
            description = locale('volume_unmute'),
            icon = 'volume-high',
        })
    else
        lastVolume = getRadioVolume()
        Voice:setRadioVolume(0)

        lib.notify({
            type = 'error',
            description = locale('volume_mute'),
            icon = 'volume-xmark',
        })
    end
end)

---@param presetId number
---@param cb fun(frequency: false | number)
RegisterNUICallback('presetJoin', function(presetId, cb)
    local frequency = tonumber(GetResourceKvpString('ac_radio:preset_' .. presetId))

    if not frequency then
        cb(false)
        return lib.notify({
            type = 'error',
            description = locale('preset_not_found'),
        })
    end

    local result = joinFrequency(frequency)
    cb(result)
end)

---@param frequency? number
RegisterNUICallback('presetRequest', function (frequency, cb)
    cb(1)

    if frequency then
        requestedFrequency = roundFrequency(frequency)
        lib.notify({
            type = 'info',
            description = locale('preset_choose'),
            duration = 10000,
        })
    end
end)

---@param presetId number
RegisterNUICallback('presetSet', function(presetId, cb)
    cb(1)

    if not requestedFrequency then return end

    SetResourceKvp('ac_radio:preset_' .. presetId, tostring(requestedFrequency))

    lib.notify({
        type = 'success',
        description = locale('preset_set', requestedFrequency),
    })

    requestedFrequency = nil
end)



-- commands
if Config.useCommand then
    TriggerEvent('chat:addSuggestion', '/radio', locale('command_open'))
    RegisterCommand('radio', openRadio, false)

    if Config.commandKey then
        RegisterKeyMapping('radio', locale('keymap_open'), 'keyboard', Config.commandKey)
    end
end

TriggerEvent('chat:addSuggestion', '/radio:clear', locale('command_clear'))
RegisterCommand('radio:clear', function()
    for i = 1, 2 do DeleteResourceKvp('ac_radio:preset_' .. i) end
    lib.notify({
        type = 'success',
        description = locale('preset_clear'),
    })
end, false)

-- events and exports
RegisterNetEvent('ac_radio:disableRadio', function()
    closeUi()
    SendNUIMessage({ action = 'closeUi' })
    Voice:setVoiceProperty('radioEnabled', false)
end)

RegisterNetEvent('ac_radio:openRadio', openRadio)
exports('openRadio', openRadio)
exports('leaveRadio', leaveFrequency)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then
        leaveFrequency()
        if isOpened then
            ClearPedTasksImmediately(cache.ped)
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
        end
    end
end)
