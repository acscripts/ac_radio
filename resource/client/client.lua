local presetFreq = nil
local radioProp = nil
local volumeState = nil
local uiOpened = false



-- Functions
local function openRadio()
	setNuiFocusAdvanced(true, true)
	SetCursorLocation(0.917, 0.873)
	SendNUIMessage({ action = 'open' })
	uiOpened = true

	-- Disarms the player when using the radio. Only for ox_inventory.
	TriggerEvent('ox_inventory:disarm')

	local model = `prop_cs_hand_radio`
	requestModel(model)
	radioProp = CreateObject(model, 0.0, 0.0, 0.0, true, true, true)
	local ped = PlayerPedId()
	AttachEntityToEntity(radioProp, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 0, true)
	SetModelAsNoLongerNeeded(model)

	local dict = getRadioDict(ped)
	requestAnimDict(dict)
	TaskPlayAnim(ped, dict, 'cellphone_text_in', 4.0, -1, -1, 50, 0, false, false, false)
	RemoveAnimDict(dict)
end

local function removeRadioProp()
	if not radioProp then return end
	DetachEntity(radioProp)
	DeleteEntity(radioProp)
	radioProp = nil
end

local function joinRadio(channel)
	if not channel then return end
	channel = round(tonumber(channel), ac.decimalStep)

	if channel <= ac.maximumFrequencies and channel > 0 then
		exports['pma-voice']:setVoiceProperty('radioEnabled', true)
		exports['pma-voice']:setRadioChannel(channel)
		notify('success', ('Joined to frequency %s MHz'):format(channel))
	else
		notify('error', 'This frequency is unavailable')
	end
end



-- NUI callbacks
RegisterNUICallback('close', function()
	setNuiFocusAdvanced(false, false)
	uiOpened = false

	if presetFreq then
		presetFreq = nil
	end

	local ped = PlayerPedId()
	local dict = getRadioDict(ped)
    StopAnimTask(ped, dict, 'cellphone_text_in', 1.0)
    Wait(100)
    requestAnimDict(dict)
    TaskPlayAnim(ped, dict, 'cellphone_text_out', 7.0, -1, -1, 50, 0, false, false, false)
    Wait(200)
    StopAnimTask(ped, dict, 'cellphone_text_out', 1.0)
	RemoveAnimDict(dict)

	removeRadioProp()
end)

RegisterNUICallback('join', function(data)
	joinRadio(data?.channel)
end)

RegisterNUICallback('leave', function()
	leaveRadio()
	notify('success', 'You\'ve disconnected from the radio')
end)

RegisterNUICallback('volume_up', function()
	local volume = volumeState and volumeState * 0.01 or exports['pma-voice']:getRadioVolume()

	if volumeState then
		volumeState = nil
		notify('inform', 'Radio unmuted', 1000)
	end

	if volume <= 0.9 then
		local newVolume = math.floor((volume + 0.1) * 100)
		exports['pma-voice']:setRadioVolume(newVolume)
		notify('inform', ('Volume increased to %s%%'):format(newVolume), 1500, 'volume-high')
	else
		notify('error', 'Maximum volume reached', 2500)
	end
end)

RegisterNUICallback('volume_down', function()
	local volume = volumeState and volumeState * 0.01 or exports['pma-voice']:getRadioVolume()

	if volumeState then
		volumeState = nil
		notify('inform', 'Radio unmuted', 1000)
	end

	if volume >= 0.2 then
		local newVolume = math.floor((volume - 0.1) * 100)
		exports['pma-voice']:setRadioVolume(newVolume)
		notify('inform', ('Volume reduced to %s%%'):format(newVolume), 1500, 'volume-low')
	else
		notify('error', 'Minimum volume reached', 2500)
	end
end)

RegisterNUICallback('volume_mute', function()
	if volumeState then
		exports['pma-voice']:setRadioVolume(volumeState)
		volumeState = nil
		notify('success', 'Radio unmuted', 5000, 'volume-high')
	else
		volumeState = math.floor(exports['pma-voice']:getRadioVolume() * 100)
		exports['pma-voice']:setRadioVolume(0)
		notify('error', 'Radio muted', 5000, 'volume-xmark')
	end
end)

RegisterNUICallback('preset_join', function(data, cb)
	if not data?.preset then return end
	local preset = GetResourceKvpString('ac_radio:preset_'.. data.preset)
	if preset then
		joinRadio(preset)
		cb(preset)
	else
		notify('error', 'No saved preset found')
	end
end)

RegisterNUICallback('preset_request', function(data)
	if data?.channel then
		notify('inform', 'Choose a preset (1 or 2) to save the current frequency on.', 10000)
		presetFreq = data.channel
	end
end)

RegisterNUICallback('preset_set', function(data)
	if not presetFreq then return end

	if not data?.preset then
		notify('error', 'Invalid frequency')
	else
		SetResourceKvp('ac_radio:preset_'.. data.preset, presetFreq)
		notify('success', ('You\'ve set the preset to %s MHz'):format(presetFreq))
		presetFreq = nil
	end
end)



-- Commands and handlers
if ac.useCommand then
	TriggerEvent('chat:addSuggestion', '/radio', 'Opens the radio UI')
	RegisterCommand('radio', function()
		openRadio()
	end)

	if ac.commandKey then
		RegisterKeyMapping('radio', 'Open radio UI', 'keyboard', ac.commandKey)
	end
end

TriggerEvent('chat:addSuggestion', '/radio:clear', 'Clears all your frequency presets')
RegisterCommand('radio:clear', function()
	for i=1, 2 do DeleteResourceKvp('ac_radio:preset_'..i) end
	notify('success', 'Radio presets cleared')
end)

exports('openRadio', openRadio)
RegisterNetEvent('ac_radio:openRadio', openRadio)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		removeRadioProp()
		leaveRadio()
		if uiOpened then
			SetNuiFocus(false, false)
			SetNuiFocusKeepInput(false)
		end
	end
end)
