

class_name MainMenu
extends Control

var root_ref: RootNode

@onready var button_PLAY: Button = %PLAY
@onready var button_CREDITS: Button = %CREDITS
@onready var button_SETTINGS: Button = %SETTINGS
@onready var button_QUIT: Button = %QUIT
@onready var button_PEN: Button = %PEN
@onready var button_group: ButtonGroup = button_PLAY.button_group

func _ready() -> void:
	Lib.Buttons.setup_buttons(button_group)
	button_group.pressed.connect(_on_button_pressed)


func _on_button_pressed(button: BaseButton) -> void:
	if not root_ref:
		root_ref = RootNode.root_ref
	await Lib.Buttons.button_delay()
	match button:
		button_PLAY:
			root_ref.current_mode = root_ref.GameMode.PLAY
		button_CREDITS:
			root_ref.current_mode = root_ref.GameMode.CREDITS
		button_SETTINGS:
			root_ref.current_mode = root_ref.GameMode.SETTINGS
		button_QUIT:
			root_ref.current_mode = root_ref.GameMode.QUIT
		button_PEN:
			root_ref.current_mode = root_ref.GameMode.PEN
