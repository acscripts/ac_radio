-- START: Custom notification --
local function customNotify(type, text, duration, icon)

	--[[
		Use any notification system you want. The one you see below is from 'ox_lib' resource (https://github.com/overextended/ox_lib).
		Examples of parameter values:
			type = 'inform'
			text = 'Volume increased to 50%'
			duration = 1500
			icon = 'volume-high'
	]]

	exports.ox_lib:notify({
		type = type,
		description = text,
		duration = duration,
		icon = icon
	})

end
-- END: Custom notification --



local typeColors = {
	['inform'] = 40,
	['success'] = 20,
	['error'] = 130
}

---@param type string
---@param text string
local function defaultNotify(type, text)
	BeginTextCommandThefeedPost('STRING')
	AddTextComponentSubstringPlayerName(text)
	ThefeedSetNextPostBackgroundColor(typeColors[type] or 140)
	EndTextCommandThefeedPostTicker(false, true)
end

---@param type string inform / success / error
---@param text string Notification text
---@param duration? number (optional) Duration in miliseconds
---@param icon? string (optional) FontAwesome 6 icon name (ie. 'circle-info')
function notify(type, text, duration, icon)
	if ac.useCustomNotify then
		customNotify(type, text, duration, icon)
	else
		defaultNotify(type, text)
	end
end

local focused = false
---@param state boolean
function setNuiFocus(state)
	SetNuiFocus(state, state)
	SetNuiFocusKeepInput(state)
	focused = state

	if focused then
		CreateThread(function()
			while focused do
				Wait(5)
				DisableAllControlActions(0)
				EnableControlAction(0, 21, true) -- INPUT_SPRINT
				EnableControlAction(0, 22, true) -- INPUT_JUMP
				EnableControlAction(0, 30, true) -- INPUT_MOVE_LR
				EnableControlAction(0, 31, true) -- INPUT_MOVE_UD
				EnableControlAction(0, 59, true) -- INPUT_VEH_MOVE_LR
				EnableControlAction(0, 71, true) -- INPUT_VEH_ACCELERATE
				EnableControlAction(0, 72, true) -- INPUT_VEH_BRAKE
			end
		end)
	end
end

---@param ped number
---@return string dict
function getRadioDict(ped)
	return IsPedInAnyVehicle(ped, false) and 'cellphone@in_car@ds' or 'cellphone@'
end

---@param model number
function requestModel(model)
	if HasModelLoaded(model) then return end
	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
	end
end

---@param dict string
function requestAnimDict(dict)
	if HasAnimDictLoaded(dict) then return end
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Wait(0)
	end
end

-- Send setup data to NUI
RegisterNUICallback('loaded', function()
	local uiLocales = {}
	for k,v in pairs(locales) do
		if k:find('ui_') then
			uiLocales[k] = v
		end
	end

	SendNUIMessage({
		action = 'setup',
		config = {
			max = ac.maximumFrequencies,
			step = ac.frequencyStep,
			locales = uiLocales
		}
	})
end)

-- Yoinked from http://lua-users.org/wiki/SimpleRound
---@param num number
---@param decimal number
function round(num, decimal)
	local mult = 10^(decimal or 0)
	return math.floor(num * mult + 0.5) / mult
end

do
	local step = tostring(ac.frequencyStep)
	local pos = step:find('%.')
	ac.decimalStep = pos and #step:sub(pos + 1) or 0
end
