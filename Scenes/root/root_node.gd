
class_name RootNode
extends Node

enum GameMode{
	MAIN_MENU, ## Should be the first scene
	SETTINGS, ## Should mirror the structure of the first scene
	CREDITS, ## Whatever we may come up with
	PLAY, ## Should point to the scene created by the 3D team
	PEN, ## Upgrades screen
	QUIT, ## Should just auto close the game
	PAUSE, ##
}

static var root_ref: RootNode

## Changing the current_mode variable will perform all the work necessary for swapping the scene.
@export var current_mode: GameMode:
	set(v):
		print_rich("[b][color=RED]  New game mode:   [/color][/b]", GameMode.find_key(v))
		_change_scene(v)
		current_mode = v


var current_scene: Node

@onready var preloaded_ui_scenes: Dictionary[GameMode, PackedScene] = {
	GameMode.MAIN_MENU: preload("uid://c1ramn8byuilg"),
	GameMode.SETTINGS: preload("uid://brl11g3oxo4y1"),
	GameMode.CREDITS: preload("uid://c7rtap1601thy"),
	GameMode.PLAY: preload("uid://b7g5whk4u801n"),
	GameMode.PEN: preload("uid://i4hgl17h5n1r"),
	GameMode.PAUSE: preload("uid://dmab3p3co23bb"),
}


func _ready() -> void:
	root_ref = self
	current_mode = current_mode


## This exists only for Dev purposes. We can peel this off later on
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		current_mode = GameMode.PAUSE

## Parses the new_mode and swaps appropriately
func _change_scene(new_mode: GameMode) -> void:
	match new_mode:
		GameMode.QUIT:
			get_tree().quit()
		_:
			current_scene = Build.root_scene(preloaded_ui_scenes[new_mode], current_scene, self)
