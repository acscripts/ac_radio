local config = require 'config'
local utils = require 'resource.client.utils'
local Voice = exports['pma-voice']

local radioProp = nil ---@type number | nil
local volumeState = nil ---@type number | nil
local requestedFrequency = nil ---@type number | nil
local uiOpened = false

lib.locale()

local function openRadio()
	if uiOpened then return end
	uiOpened = true

	utils.setNuiFocus(true)
	SetCursorLocation(0.917, 0.873)
	SendNUIMessage({ action = 'open' })

	-- Disarms the player when using the radio. Only for ox_inventory.
	TriggerEvent('ox_inventory:disarm')

	local model = `prop_cs_hand_radio`
	lib.requestModel(model)
	radioProp = CreateObject(model, 0.0, 0.0, 0.0, true, true, true)
	AttachEntityToEntity(radioProp, cache.ped, GetPedBoneIndex(cache.ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 0, true)
	SetModelAsNoLongerNeeded(model)

	local dict = utils.getRadioDict()
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
---@return false | number
local function joinRadio(channel)
	if not channel then return false end

	channel = utils.round(channel, utils.decimalStep)

	if channel <= config.maximumFrequencies and channel > 0 then
		Voice:setVoiceProperty('radioEnabled', true)
		Voice:setRadioChannel(channel)

		if not config.restrictedChannels[channel] then
			utils.notify('success', locale('channel_join', channel))
		end

		return channel
	else
		utils.notify('error', locale('channel_unavailable'))
		return false
	end
end

local function leaveRadio()
	Voice:removePlayerFromRadio()
	Voice:setVoiceProperty('radioEnabled', false)
end



RegisterNUICallback('close', function(_, cb)
	cb(1)
	utils.setNuiFocus(false)

	if requestedFrequency then
		requestedFrequency = nil
	end

	local dict = utils.getRadioDict()
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

---@param frequency number
---@param cb fun(frequency: false | number)
RegisterNUICallback('join', function(frequency, cb)
	local roundedFrequency = joinRadio(frequency)
	cb(roundedFrequency)
end)

RegisterNUICallback('leave', function(_, cb)
	cb(1)
	leaveRadio()
	utils.notify('success', locale('channel_disconnect'))
end)

RegisterNUICallback('volume_up', function(_, cb)
	cb(1)

	local volume = volumeState or Voice:getRadioVolume()

	if volumeState then
		volumeState = nil
		utils.notify('inform', locale('volume_unmute'), 1000)
	end

	if volume <= 90 then
		volume += 10
		Voice:setRadioVolume(volume)
		utils.notify('inform', locale('volume_up', math.floor(volume)), 1500, 'volume-high')
	else
		utils.notify('error', locale('volume_max'), 2500)
	end
end)

RegisterNUICallback('volume_down', function(_, cb)
	cb(1)

	local volume = volumeState or Voice:getRadioVolume()

	if volumeState then
		volumeState = nil
		utils.notify('inform', locale('volume_unmute'), 1000)
	end

	if volume >= 20 then
		volume -= 10
		Voice:setRadioVolume(volume)
		utils.notify('inform', locale('volume_down', math.floor(volume)), 1500, 'volume-low')
	else
		utils.notify('error', locale('volume_min'), 2500)
	end
end)

RegisterNUICallback('volume_mute', function(_, cb)
	cb(1)

	if volumeState then
		Voice:setRadioVolume(volumeState)
		volumeState = nil
		utils.notify('success', locale('volume_unmute'), 5000, 'volume-high')
	else
		volumeState = Voice:getRadioVolume()
		Voice:setRadioVolume(0)
		utils.notify('error', locale('volume_mute'), 5000, 'volume-xmark')
	end
end)

---@param presetId number
---@param cb fun(preset: false | number)
RegisterNUICallback('preset_join', function(presetId, cb)
	local frequency = tonumber(GetResourceKvpString('ac_radio:preset_'.. presetId))
	if not frequency then
		cb(false)
		utils.notify('error', locale('preset_not_found'))
	else
		local roundedFrequency = joinRadio(frequency)
		cb(roundedFrequency)
	end
end)

---@param frequency number
RegisterNUICallback('preset_request', function(frequency, cb)
	cb(1)

	if frequency then
		utils.notify('inform', locale('preset_choose'), 10000)
		requestedFrequency = utils.round(frequency, utils.decimalStep)
	end
end)

---@param presetId number
RegisterNUICallback('preset_set', function(presetId, cb)
	cb(1)

	if not requestedFrequency then return end

	if not presetId then
		utils.notify('error', locale('preset_invalid'))
	else
		SetResourceKvp('ac_radio:preset_'.. presetId, tostring(requestedFrequency))
		utils.notify('success', locale('preset_set', requestedFrequency))
		requestedFrequency = nil
	end
end)



if config.useCommand then
	TriggerEvent('chat:addSuggestion', '/radio', locale('command_open'))
	RegisterCommand('radio', function()
		openRadio()
	end, false)

	if config.commandKey then
		RegisterKeyMapping('radio', locale('keymap_open'), 'keyboard', config.commandKey)
	end
end

TriggerEvent('chat:addSuggestion', '/radio:clear', locale('command_clear'))
RegisterCommand('radio:clear', function()
	for i = 1, 2 do DeleteResourceKvp('ac_radio:preset_'..i) end
	utils.notify('success', locale('preset_clear'))
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
			utils.setNuiFocus(false)
		end
	end
end)
