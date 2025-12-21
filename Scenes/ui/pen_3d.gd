extends Node3D

@onready var camera: Camera3D = %ActiveCamera
@onready var main_menu_camera: Camera3D = %MainMenuCamera
@onready var pen_camera: Camera3D = %PenCamera
@onready var reindeer: Reindeer = %Reindeer


const PEN_COLLECTIBLE := preload("res://Scenes/collectibles/pen_collectible.tscn")
const camera_tween_time_seconds := 1


func _ready() -> void:
	GameState.new_state.connect(_on_game_state_changed)
	if GameState.current == GameState.State.PEN:
		camera.global_transform = pen_camera.global_transform
	for i: Item in GameStats.collectibles_collected:
		var c := PEN_COLLECTIBLE.instantiate()
		add_child(c)
		c.item = i
		var offset := Vector3(randf_range(0.0, 0.5),randf_range(0.0, 0.5),randf_range(0.0, 0.5))
		c.global_transform = %CollectibleEmitter.global_transform.translated(offset)


func _process(delta: float) -> void:
	var l := %FireLight as OmniLight3D
	l.light_energy = clampf(l.light_energy + randf_range(-0.1, 0.1), 0.5, 1.0)
	var offset := Vector3(randf_range(0.0, 0.5),randf_range(0.0, 0.5),randf_range(0.0, 0.25))
	l.transform.origin = (l.transform.origin + offset).clampf(-0.5, 0.5)

func _on_game_state_changed(new_state: GameState.State, old_state: GameState.State):
	print("state change new_state: %s, old_state: %s" % [
		GameState.State.keys()[new_state],
		GameState.State.keys()[old_state],
	])
	if new_state == GameState.State.PEN and \
	old_state in [GameState.State.STARTUP, GameState.State.MAIN_MENU]:
		var tween = create_tween()
		tween.tween_property(
			camera, "global_transform", pen_camera.global_transform,
			camera_tween_time_seconds
		)


func _on_apple_ate_apple() -> void:
	reindeer.pellet_producer.max_pellet_time = 20.0
	reindeer.pellet_producer.emit_pellets()
