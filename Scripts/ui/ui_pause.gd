
class_name UiPause
extends Control


@onready var button_MAIN_MENU: Button = %MAIN_MENU
@onready var button_QUIT: Button = %QUIT
@onready var button_group: ButtonGroup = button_QUIT.button_group


func _ready() -> void:
	UiLib.Buttons.setup_buttons(button_group)
	button_group.pressed.connect(_on_button_pressed)


func _on_button_pressed(button: BaseButton) -> void:
	await UiLib.Buttons.button_delay(button)
	match button.name:
		"MAIN_MENU":
			GameState.current = GameState.State.MAIN_MENU
		"QUIT":
			await UiLib.Buttons.button_delay(button)
			get_tree().quit()
