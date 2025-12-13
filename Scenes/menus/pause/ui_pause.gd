
class_name UiPause
extends Control

@onready var button_MAIN_MENU: Button = %MAIN_MENU
@onready var button_QUIT: Button = %QUIT
@onready var button_group: ButtonGroup = button_QUIT.button_group

func _ready() -> void:
	Lib.Buttons.name_them(button_group)
	button_group.pressed.connect(_on_button_pressed)


func _on_button_pressed(button: BaseButton) -> void:
	match button:
		button_MAIN_MENU:
			RootNode.root_ref.current_mode = RootNode.root_ref.GameMode.MAIN_MENU
		button_QUIT:
			get_tree().quit()
