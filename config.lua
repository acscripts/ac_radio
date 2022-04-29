ac = {
	-- Whether to use custom notification function located in top of the 'resource/utils.lua' file.
	-- If set to 'true', the default custom notification system is from 'ox_lib' resource.
	useCustomNotify = false,

	--[[
		Whether to use command for opening the radio UI.
		If set to 'false', you need to do some additional steps to set up the item in your inventory system.
		You can find guides for the most popular inventories/frameworks in the 'docs' folder.

		Event usage (client or server, just use TriggerClientEvent):
			TriggerEvent('ac_radio:openRadio')

		Export usage (client only):
			exports.ac_radio:openRadio()
	]]
	useCommand = true,

	--[[
		Default keybind for the '/radio' command. Use only if the option above ('useCommand') is set to 'true'.
		You can find a list of all valid keys there: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/

		Set it to any valid key if you want the command to be binded to that key by default (ex. 'NUMPAD0').
		Leave it empty if you don't want a default keybind.
		Set it to 'false' if you want do disable keybind for the command.
	]]
	commandKey = ''
}
