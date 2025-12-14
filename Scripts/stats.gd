extends Node
class_name Stats

var collectibles_collected: Array[Item] = []
var travel_distance: float = 0

func collect_item(item: Item):
	collectibles_collected.append(item)
