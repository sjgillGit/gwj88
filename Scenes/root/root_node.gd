
class_name RootNode
extends Node

enum GameMode{
	MAIN_MENU, ## Should be the first scene
	SETTINGS, ## Should mirror the structure of the first scene
	CREDITS, ## Whatever we may come up with
	PLAY, ## Should point to the scene created by the 3D team
	QUIT, ## Should just auto close the game
}

## Changing the current_game_mode variable will perform
## all the work necessary for swapping the scene.
@export var current_game_mode: GameMode:
	set(v):
		_change_scene(v)
		current_game_mode = v
var current_scene


func _ready() -> void:
	current_game_mode = current_game_mode


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		match current_game_mode:
			#GameMode.PLAY:
				#pass              # OPEN PAUSE
			GameMode.MAIN_MENU:
				current_game_mode = GameMode.QUIT
			_:
				current_game_mode = GameMode.MAIN_MENU


## Parses the new_game_mode and swaps appropriately
func _change_scene(new_game_mode: GameMode) -> void:
	print_rich("[b][color=RED]  New game mode:   [/color][/b]", GameMode.find_key(new_game_mode))
	if new_game_mode == GameMode.QUIT:
		get_tree().quit()
	else:
		var new_scene = GlobalPreloader.get_resource(GameMode.find_key(new_game_mode)).instantiate()
		if current_scene:
			current_scene.queue_free()
		add_child(new_scene)
		current_scene = new_scene
