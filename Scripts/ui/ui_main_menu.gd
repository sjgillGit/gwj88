

class_name UiMainMenu
extends Control

@onready var button_group: ButtonGroup = %PLAY.button_group

func _ready() -> void:
	UiLib.Buttons.setup_buttons(button_group)
	button_group.pressed.connect(_on_button_pressed)


func _on_button_pressed(button: BaseButton) -> void:
	await UiLib.Buttons.button_delay(button)
	match button.name:
		"PLAY":
			GameState.current = GameState.State.PLAY
		"CREDITS":
			GameState.current = GameState.State.CREDITS
		"SETTINGS":
			GameState.current = GameState.State.SETTINGS
		"QUIT":
			GameState.current = GameState.State.QUIT
		"PEN":
			GameState.current = GameState.State.PEN
