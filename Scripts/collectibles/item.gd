@tool
extends Resource
class_name Item

@export var name: String
@export var asset: PackedScene:
	set(value):
		asset = value
		emit_changed()
