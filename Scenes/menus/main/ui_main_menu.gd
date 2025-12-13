

class_name MainMenu
extends Control

@onready var button_PLAY: Button = %PLAY
@onready var button_CREDITS: Button = %CREDITS
@onready var button_SETTINGS: Button = %SETTINGS
@onready var button_QUIT: Button = %QUIT
@onready var button_PEN: Button = %PEN
@onready var button_group: ButtonGroup = button_PLAY.button_group


func _ready() -> void:
	Lib.Buttons.name_them(button_group)
	button_group.pressed.connect(_on_button_pressed)


func _on_button_pressed(button: BaseButton) -> void:
	match button:
		button_PLAY:
			RootNode.root_ref.current_mode = RootNode.root_ref.GameMode.PLAY
		button_CREDITS:
			RootNode.root_ref.current_mode = RootNode.root_ref.GameMode.CREDITS
		button_SETTINGS:
			RootNode.root_ref.current_mode = RootNode.root_ref.GameMode.SETTINGS
		button_QUIT:
			RootNode.root_ref.current_mode = RootNode.root_ref.GameMode.QUIT
		button_PEN:
			RootNode.root_ref.current_mode = RootNode.root_ref.GameMode.PEN
