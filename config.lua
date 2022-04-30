ac = {
	-- Whether to use custom notification function located in top of the 'resource/client/utils.lua' file.
	-- If set to 'true', the default custom notification system is from 'ox_lib' resource.
	useCustomNotify = false,

	--[[
		Whether to use command for opening the radio UI.
		If set to 'false', you need to do some additional steps to set up the item in your inventory system.
		You can find guides for the most popular inventories/frameworks in the 'docs' folder.
	]]
	useCommand = true,

	--[[
		Default keybind for the '/radio' command. Use only if the option above ('useCommand') is set to 'true'.
		You can find a list of all valid keys there: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/

		Set it to any valid key if you want the command to be binded to that key by default (ex. 'NUMPAD0').
		Leave it empty if you don't want a default keybind.
		Set it to 'false' if you want do disable keybind for the command.
	]]
	commandKey = '',

	-- Number of available frequencies
	maximumFrequencies = 1000,

	-- How much the frequency value can change per step (5.23, 5.24, 5.25)
	frequencyStep = 0.01,

	--[[
		Channel restrictions use the following format. The term 'group' is the same as 'job'.

		For single group:
			[frequency] = 'group'
		Frequency '1' will be restricted to group 'police' (everyone with group 'police' can access it).
			[1] = 'police'

		For multiple groups and grades:
			[frequency] = {
				group = grade
			}
		Frequency '1.1' will be restricted to groups 'police' (grade below 3 can't access it) and 'fbi' (everyone with group 'fbi' can access it).
			[1.1] = {
				police = 3,
				fbi = 0
			}
	]]
	restrictedChannels = {
		[1] = 'police',
		[1.1] = {
			police = 3,
			fbi = 0
		}
	}
}
