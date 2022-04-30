# [ox_inventory](https://github.com/overextended/ox_inventory)
Creating a new item in ox_inventory is really easy.  
Add the following snippet to `ox_inventory/data/items.lua`. The item image is already there by default.

```lua
['radio'] = {
	label = 'Radio',
	weight = 100,
	stack = true,
	close = true,
	client = {
		export = 'ac_radio.openRadio',
		remove = function(total)
			-- Disconnets a player from the radio when all his radio items are removed.
			if total < 1 then
				exports.ac_radio:leaveRadio()
			end
		end
	}
}
```

For more detailed steps, visit the official ["Creating items"](https://overextended.github.io/docs/ox_inventory/Guides/creatingItems) guide.
