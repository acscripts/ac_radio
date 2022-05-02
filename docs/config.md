# Config explanation
In this file you can find more detailed description of each config option.

<details>
<summary><b>Quick navigation</b></summary>

- [locale](#locale)
- [versionCheck](#versioncheck)
- [useCustomNotify](#usecustomnotify)
- [useCommand](#usecommand)
- [commandKey](#commandkey)
- [maximumFrequencies](#maximumfrequencies)
- [frequencyStep](#frequencystep)
- [restrictedChannels](#restrictedchannels)
</details>

<br>

## locale
What supported language to use for notifications and UI.  
Locale name is the same as the file name in [locales](../locales) folder without the `.lua` extension (eg. **en**, **cs**).  
Note that some character sets may not be supported when using the default notifications (eg. `ěčřůďťň`).  
Feel free to submit a PR with more languages!

**Accepted values**  
`'en'` = Or any other locale.



## versionCheck
Whether to check for newer resource version and notify in server console.

**Accepted values**  
`true` = You will be notified in server console when a newer version of **ac_radio** is available.  
`false` = You will need to manually check for a newer version on GitHub 👎🏽



## useCustomNotify
Whether to use custom notification function located in [utils.lua](../resource/client/utils.lua) in **customNotify**.  
If you have [ox_lib](https://github.com/overextended/ox_lib) resource running, you can set this to `true` and not worry about anything else.  
Otherwise, you must add your own notification code snippet to the **customNotify** function.

**Accepted values**  
`true` = The code inside **customNotify** function will be used insted of the default notification.  
`false` = The default GTA V notifications will be used.



## useCommand
Whether to use command for opening the radio UI.

**Accepted values**  
`true` = A command to open the radio will be created.  
`false` = It will only be possible to open the radio UI using an item (if you're using one of the supported frameworks) or using the following snippets.

**Snippets**  
```lua
-- Export
exports.ac_radio:openRadio()

-- Event
TriggerEvent('ac_radio:openRadio')
TriggerClientEvent('ac_radio:openRadio', source)
```



## commandKey
Default keybind for the radio command. Use only if the option above (**useCommand**) is set to `true`.

**Accepted values**  
`false` = The keybind will not be created at all.  
`''` = Empty quotes for creating the keybind, but not setting a default key.   
`'NUMPAD0'` = Or any other [valid key](https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard) to create a keybind with **this** default key.



## maximumFrequencies
Maximum number of available channel frequencies.  
Frequency range will be <u>**from more than 0 to this value inclusive**</u>.

**Accepted values**  
`number` = Self explanatory.



## frequencyStep
How much the frequency value can change per step.  
If set to `0.01`, available frequencies will be **32.56**, **32.57**, **32.58** etc. Can be an integer as well.

**Accepted values**  
`number` = Self explanatory.



## restrictedChannels
###### In the following text, the term "group" has the same meaning as "job".
Restricts certain channel frequencies for given groups and grades.  
Each specific frequency must be listed separately.

**Accepted values**  
Table of any amount of frequencies
```lua
-- Single group without grade (any grade in this group can access it)
[frequency] = 'group'

-- Single group with grade
[frequency] = {
    group = grade
}

-- Multiple groups
[frequency] = {
    group1 = grade1,
    group2 = grade2,
    group3 = grade3
}
```

**Example config data**
```lua
restrictedChannels = {
    [1] = {
        police = 5,         -- Everyone with group "police" and grade >=5 can access 1 MHz
        ambulance = 7,      -- Everyone with group "ambulance" and grade >=7 can access 1 MHz
        fbi = 0             -- Everyone with group "fbi" can access 1 MHz
    },
    [1.1] = 'police',       -- Everyone with group "police" can access 1.1 MHz
    [1.2] = 'ambulance',    -- Everyone with group "ambulance" can access 1.2 MHz
    [1.3] = 'fbi'           -- Everyone with group "fbi" can access 1.3 MHz
}
```
