extends Node3D

@onready var camera: Camera3D = %ActiveCamera
@onready var main_menu_camera: Camera3D = %MainMenuCamera
@onready var pen_camera: Camera3D = %PenCamera


const camera_tween_time_seconds := 1


func _ready() -> void:
	GameState.new_state.connect(_on_game_state_changed)


func _on_game_state_changed(new_state: GameState.State, old_state: GameState.State):
	print("state change new_state: %s, old_state: %s" % [
		GameState.State.keys()[new_state],
		GameState.State.keys()[old_state],
	])
	if new_state == GameState.State.PEN and \
	old_state in [GameState.State.STARTUP, GameState.State.MAIN_MENU]:
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(
			camera, "position", pen_camera.position,
			camera_tween_time_seconds
		)
		tween.tween_property(
			camera, "rotation", pen_camera.rotation,
			camera_tween_time_seconds
		)
