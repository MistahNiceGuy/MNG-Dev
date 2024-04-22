# mng-pizzadelivery
 Pizza Delivery Job With Levelling System


Add the following code to qb-core>server>player.lua underneath PlayerData.metadata = PlayerData.metadata or {} which should be on line 110

PlayerData.metadata['pizzaexp'] = PlayerData.metadata['pizzaexp'] or 0
PlayerData.metadata['pizzalevel'] = PlayerData.metadata['pizzalevel'] or 0