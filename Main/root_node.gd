extends Node3D

var _old_scene: PackedScene = null
var _old_instance: Node = null

func _ready():
	GameState.new_state.connect(_game_state_changed)
	_game_state_changed(GameState.current, GameState.State.STARTUP)

func _game_state_changed(new_state: GameState.State, _old_state: GameState.State):
	var new_scene: PackedScene = null
	if new_state == GameState.State.REPLAY:
		# force a restart
		_old_scene = null
		new_state = GameState.State.PLAY
	match new_state:
		GameState.State.STARTUP, GameState.State.MAIN_MENU, GameState.State.PEN, GameState.State.CREDITS, GameState.State.SETTINGS, GameState.State.PAUSE:
			new_scene = preload("res://Scenes/ui/Pen3D.tscn")
		GameState.State.PLAY:
			new_scene = preload("res://Scenes/flight_mode/flight_main.tscn")
		GameState.State.QUIT:
			pass
		GameState.State.ENDING_WIN:
			new_scene = preload("res://Scenes/ui/endings/ending_win.tscn")
		GameState.State.ENDING_SPACE:
			new_scene = preload("res://Scenes/ui/endings/ending_space.tscn")
		GameState.State.ENDING_BEACH:
			new_scene = preload("res://Scenes/ui/endings/ending_beach.tscn")
		GameState.State.ENDING_HOLE:
			new_scene = preload("res://Scenes/ui/endings/ending_hole.tscn")
		_:
			assert(false, "I don't know what to do here with this new game state: %s" % [new_state])
	if _old_scene != new_scene:
		# get_tree().change_scene_to_packed() will delete root_node, so we can't use that..
		if _old_instance:
			_old_instance.queue_free()
		_old_scene = new_scene
		if new_scene:
			var scene_instance = new_scene.instantiate()
			_old_instance = scene_instance
			add_child(scene_instance)
