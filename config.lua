-----------------------------------------------------------------
-- Visit https://docs.acscripts.dev/radio for documentation
-----------------------------------------------------------------

return {
    -- Enable usable item for opening the radio
    useUsableItem = true,

    -- Enable command for opening the radio
    useCommand = true,

    -- Default keybind for the '/radio' command
    commandKey = '',

    -- Enable disconnecting from frequency when there is no radio item left in player's inventory
    disconnectWithoutRadio = true,

    -- Percentage of volume to increase/decrease per step
    volumeStep = 10,

    -- Frequency decimal precision
    frequencyStep = 0.01,

    -- Maximum amount of available frequencies (starting from 0)
    maximumFrequencies = 1000,

    -- Frequency restrictions for channels
    restrictedChannels = {
        [10] = 'police',
        [11] = {
            police = 2,
        },
    },

    -- ! The following options will override pma-voice convars
    -- Enable radio voice effect (voice sounds like on a real radio)
    radioEffect = true,

    -- Enable animation while talking on radio
    radioAnimation = true,

    -- Default keybind for talking on radio
    radioTalkKey = 'LMENU',
}
