extends Node3D
class_name Collectible

@export var item: Item

func _ready() -> void:
	add_child(item.asset.instantiate())
