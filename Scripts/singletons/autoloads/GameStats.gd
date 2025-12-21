extends Node

signal money_changed
signal collectibles_changed

var coins_collected := 0
var collectibles_collected: Array[Item] = []
var travel_distance: float = 0

func collect_item(item: Item):
	# use preload so if you move it it will auto-update
	if item.resource_path == preload("res://Scripts/collectibles/star_coin.tres").resource_path:
		money += 1
		money_changed.emit()
	else:
		collectibles_collected.append(item)
		collectibles_changed.emit()


var money: int:
	set(v):
		money = v
		money_changed.emit()
