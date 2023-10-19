local radioProp = nil ---@type number | nil
local volumeState = nil ---@type number | nil
local requestedFrequency = nil ---@type number | nil
local uiOpened = false

local Voice = exports['pma-voice']

lib.locale()

local function openRadio()
	if uiOpened then return end
	uiOpened = true

	setNuiFocus(true)
	SetCursorLocation(0.917, 0.873)
	SendNUIMessage({ action = 'open' })

	-- Disarms the player when using the radio. Only for ox_inventory.
	TriggerEvent('ox_inventory:disarm')

	local model = `prop_cs_hand_radio`
	lib.requestModel(model)
	radioProp = CreateObject(model, 0.0, 0.0, 0.0, true, true, true)
	AttachEntityToEntity(radioProp, cache.ped, GetPedBoneIndex(cache.ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 0, true)
	SetModelAsNoLongerNeeded(model)

	local dict = getRadioDict()
	lib.requestAnimDict(dict)
	TaskPlayAnim(cache.ped, dict, 'cellphone_text_in', 4.0, -1, -1, 50, 0, false, false, false)
	RemoveAnimDict(dict)
end

local function removeRadioProp()
	if not radioProp then return end
	DetachEntity(radioProp, false, false)
	DeleteEntity(radioProp)
	radioProp = nil
end

---@param channel number?
local function joinRadio(channel)
	if not channel then return end
	channel = round(channel, ac.decimalStep)

	if channel <= ac.maximumFrequencies and channel > 0 then
		Voice:setVoiceProperty('radioEnabled', true)
		Voice:setRadioChannel(channel)

		if not ac.restrictedChannels[channel] then
			notify('success', locale('channel_join', channel))
		end
	else
		notify('error', locale('channel_unavailable'))
	end
end

local function leaveRadio()
	Voice:removePlayerFromRadio()
	Voice:setVoiceProperty('radioEnabled', false)
end



---@class ChannelData
---@field frequency number

---@class PresetData
---@field presetId number

RegisterNUICallback('close', function()
	setNuiFocus(false)

	if requestedFrequency then
		requestedFrequency = nil
	end

	local dict = getRadioDict()
	StopAnimTask(cache.ped, dict, 'cellphone_text_in', 1.0)
	Wait(100)
	lib.requestAnimDict(dict)
	TaskPlayAnim(cache.ped, dict, 'cellphone_text_out', 7.0, -1, -1, 50, 0, false, false, false)
	Wait(200)
	StopAnimTask(cache.ped, dict, 'cellphone_text_out', 1.0)
	RemoveAnimDict(dict)

	removeRadioProp()
	uiOpened = false
end)

---@param data ChannelData
RegisterNUICallback('join', function(data)
	joinRadio(data?.frequency)
end)

RegisterNUICallback('leave', function()
	leaveRadio()
	notify('success', locale('channel_disconnect'))
end)

RegisterNUICallback('volume_up', function()
	local volume = volumeState or Voice:getRadioVolume()

	if volumeState then
		volumeState = nil
		notify('inform', locale('volume_unmute'), 1000)
	end

	if volume <= 90 then
		volume += 10
		Voice:setRadioVolume(volume)
		notify('inform', locale('volume_up', math.floor(volume)), 1500, 'volume-high')
	else
		notify('error', locale('volume_max'), 2500)
	end
end)

RegisterNUICallback('volume_down', function()
	local volume = volumeState or Voice:getRadioVolume()

	if volumeState then
		volumeState = nil
		notify('inform', locale('volume_unmute'), 1000)
	end

	if volume >= 20 then
		volume -= 10
		Voice:setRadioVolume(volume)
		notify('inform', locale('volume_down', math.floor(volume)), 1500, 'volume-low')
	else
		notify('error', locale('volume_min'), 2500)
	end
end)

RegisterNUICallback('volume_mute', function()
	if volumeState then
		Voice:setRadioVolume(volumeState)
		volumeState = nil
		notify('success', locale('volume_unmute'), 5000, 'volume-high')
	else
		volumeState = Voice:getRadioVolume()
		Voice:setRadioVolume(0)
		notify('error', locale('volume_mute'), 5000, 'volume-xmark')
	end
end)

---@param data PresetData
---@param cb fun(preset: number)
RegisterNUICallback('preset_join', function(data, cb)
	if not data?.presetId then return end

	local frequency = tonumber(GetResourceKvpString('ac_radio:preset_'.. data.presetId))
	if not frequency then
		notify('error', locale('preset_not_found'))
	else
		joinRadio(frequency)
		cb(frequency)
	end
end)

---@param data ChannelData
RegisterNUICallback('preset_request', function(data)
	if data?.frequency then
		notify('inform', locale('preset_choose'), 10000)
		requestedFrequency = data.frequency
	end
end)

---@param data PresetData
RegisterNUICallback('preset_set', function(data)
	if not data or not requestedFrequency then return end

	if not data.presetId then
		notify('error', locale('preset_invalid'))
	else
		SetResourceKvp('ac_radio:preset_'.. data.presetId, tostring(requestedFrequency))
		notify('success', locale('preset_set', requestedFrequency))
		requestedFrequency = nil
	end
end)



if ac.useCommand then
	TriggerEvent('chat:addSuggestion', '/radio', locale('command_open'))
	RegisterCommand('radio', function()
		openRadio()
	end, false)

	if ac.commandKey then
		RegisterKeyMapping('radio', locale('keymap_open'), 'keyboard', ac.commandKey)
	end
end

TriggerEvent('chat:addSuggestion', '/radio:clear', locale('command_clear'))
RegisterCommand('radio:clear', function()
	for i = 1, 2 do DeleteResourceKvp('ac_radio:preset_'..i) end
	notify('success', locale('preset_clear'))
end, false)

RegisterNetEvent('ac_radio:disableRadio', function()
	Voice:setVoiceProperty('radioEnabled', false)
end)

RegisterNetEvent('ac_radio:openRadio', openRadio)
exports('openRadio', openRadio)
exports('leaveRadio', leaveRadio)

AddEventHandler('onResourceStop', function(resource)
	if resource == cache.resource then
		removeRadioProp()
		leaveRadio()
		if uiOpened then
			SetNuiFocus(false, false)
			SetNuiFocusKeepInput(false)
		end
	end
end)
