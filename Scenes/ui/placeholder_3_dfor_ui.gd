extends Node3D

@onready var main_menu_camera: Camera3D = $MainMenuCamera


func on_game_state_changed(new_state: GameState.State, old_state: GameState.State):
	if new_state == GameState.State.PEN and old_state == GameState.State.MAIN_MENU:
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property()
