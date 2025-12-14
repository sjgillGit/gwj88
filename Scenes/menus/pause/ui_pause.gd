
class_name UiPause
extends Control

var root_ref: RootNode

@onready var button_MAIN_MENU: Button = %MAIN_MENU
@onready var button_QUIT: Button = %QUIT
@onready var button_group: ButtonGroup = button_QUIT.button_group


func _ready() -> void:
	Lib.Buttons.setup_buttons(button_group)
	button_group.pressed.connect(_on_button_pressed)


func _on_button_pressed(button: BaseButton) -> void:
	if not root_ref:
		root_ref = RootNode.root_ref
	match button:
		button_MAIN_MENU:
			root_ref.current_mode = root_ref.GameMode.MAIN_MENU
		button_QUIT:
			await Lib.Buttons.button_delay()
			get_tree().quit()
