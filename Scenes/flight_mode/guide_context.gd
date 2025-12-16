extends Node

@export var game_context: GUIDEMappingContext

func _ready() -> void:
	GUIDE.enable_mapping_context(game_context)
