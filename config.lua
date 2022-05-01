---------------------------------------------------------------------------------------------
-- More detailed description of each config option can be found in 'docs/config.md' file.
---------------------------------------------------------------------------------------------

ac = {
	-- Language for notifications and UI
	locale = 'en',

	-- Whether to check for newer resource version and notify in server console.
	versionCheck = true,

	-- Whether to use custom notification function.
	useCustomNotify = false,

	-- Whether to use command for opening the radio UI.
	useCommand = true,

	-- Default keybind for the '/radio' command.
	commandKey = '',

	-- Number of available frequencies.
	maximumFrequencies = 1000,

	-- How much the frequency value can change per step.
	frequencyStep = 0.01,

	-- Channel frequency restrictions.
	restrictedChannels = {
		[1] = 'police'
	}
}
