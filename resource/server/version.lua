-- Yoinked from https://github.com/overextended/ox_lib/blob/48728f0241da56b15f129fd4bcf394ccb01a95b9/resource/version/server.lua#L1
if ac.versionCheck then
	SetTimeout(1000, function()
		local resource = GetCurrentResourceName()

		PerformHttpRequest('https://api.github.com/repos/antond15/ac_radio/releases/latest', function(status, response)
			if status ~= 200 then return end

			response = json.decode(response)
			if response.prerelease then return end

			local currentVersion = GetResourceMetadata(resource, 'version', 0):match('%d%.%d+%.%d+')
			if not currentVersion then return end

			local latestVersion = response.tag_name:match('%d%.%d+%.%d+')
			if not latestVersion then return end

			if currentVersion >= latestVersion then return end

			print(('^3An update is available for ac_radio (current version: %s)\r\n%s^0'):format(currentVersion, response.html_url))
		end, 'GET')
	end)
end
