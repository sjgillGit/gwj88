extends Node3D

func _on_button_pressed() -> void:
	GameState.current = GameState.State.PLAY
