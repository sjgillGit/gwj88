extends Node3D

@onready var camera: Camera3D = %ActiveCamera
@onready var main_menu_camera: Camera3D = %MainMenuCamera
@onready var pen_camera: Camera3D = %PenCamera
@onready var reindeer: Reindeer = %Reindeer


const camera_tween_time_seconds := 1


func _ready() -> void:
	GameState.new_state.connect(_on_game_state_changed)

	## TODO remove this once Quick time testing complete
	var qte: QuickTimeEventScreen.QTE = QuickTimeEventScreen.add_quick_time_event(
		"Quick Time Test",
		3,
		5.0,
		func(action_taken):
			print("Quick Time Test Callable: %s" % action_taken)
	)
	qte.completion.connect(func(action_taken: bool):
		print("Quick Time Test signal: %s" % action_taken)
	)
	QuickTimeEventScreen.add_quick_time_event(
		"Longer Quick Time Test",
		2,
		10.0,
	)
	QuickTimeEventScreen.add_quick_time_event(
		"Infinite Time Quick Time",
		1,
		0.0,
	)


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


func _on_apple_ate_apple() -> void:
	reindeer.pellet_producer.max_pellet_time = 20.0
	reindeer.pellet_producer.emit_pellets()
