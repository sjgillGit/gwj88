

class_name MainMenu
extends Control

@onready var root_node: RootNode = get_parent()
@onready var button_play: Button = %PLAY
@onready var button_credits: Button = %CREDITS
@onready var button_settings: Button = %SETTINGS
@onready var button_quit: Button = %QUIT
@onready var button_group: ButtonGroup = button_play.button_group


func _ready() -> void:
	for button in button_group.get_buttons():
		button.text = button.name
	button_group.pressed.connect(_on_button_pressed)


func _on_button_pressed(button: BaseButton) -> void:
	match button:
		button_play:
			root_node.current_game_mode = root_node.GameMode.PLAY
		button_credits:
			root_node.current_game_mode = root_node.GameMode.CREDITS
		button_settings:
			root_node.current_game_mode = root_node.GameMode.SETTINGS
		button_quit:
			root_node.current_game_mode = root_node.GameMode.QUIT
