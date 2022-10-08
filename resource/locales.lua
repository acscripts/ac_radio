local file = LoadResourceFile('ac_radio', ('locales/%s.lua'):format(ac.locale))
if not file then
	file = LoadResourceFile('ac_radio', 'locales/en.lua')
	CreateThread(function()
		error(('Locale file "%s" not found, fallbacking to default "en".'):format(ac.locale), 0)
	end)
end

local data, err = load(file)
if err then error(err) end

---@diagnostic disable-next-line: need-check-nil
locales = data()

---@param key string
---@return string
function locale(key, ...)
	if locales[key] then
		return locales[key]:format(...)
	end
	return key
end
