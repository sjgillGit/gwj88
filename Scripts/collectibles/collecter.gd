extends Node3D
class_name Collecter

signal item_collected(item: Item)

func _on_area_entered(area) -> void:
	if area is Collectible:
		item_collected.emit(area.item)
		GameStats.collect_item(area.item)
		if area.item.big_pickup_sound:
			$CollectBigAudio.play()
		else:
			$CollectSmallAudio.play()
		area.queue_free()
