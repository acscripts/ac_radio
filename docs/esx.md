# [es_extended](https://github.com/esx-framework/esx-legacy)
> If you are using [ox_inventory](https://github.com/overextended/ox_inventory) with ESX, ignore this guide and head to the [ox.md](ox.md).

Create a new item in your database. You can run the following SQL command.  
Usable item will be created automatically after starting this resource.
```sql
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('radio', 'Radio', 1, 0, 1);
```

Add an image to your inventory which you can find [here](./radio.png).
