@tool
extends Resource
class_name Item

@export var name: String
@export var game_scale := 2.0:
	set(value):
		game_scale = value
		emit_changed()

@export var asset: PackedScene:
	set(value):
		asset = value
		emit_changed()

@export var big_pickup_sound := true:
	set(value):
		big_pickup_sound = value
		emit_changed()

@export var color := Color.BLACK:
	set(value):
		color = value
		emit_changed()
