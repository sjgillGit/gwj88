
class_name UiStartup
extends Control


func _on_visibility_changed() -> void:
	if visible:
		GameState.current = GameState.State.MAIN_MENU
