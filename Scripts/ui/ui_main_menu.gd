

class_name UiMainMenu
extends Control


func _ready() -> void:
	UiLib.Buttons.setup_buttons(%PLAY.button_group, Callable(self, &"_on_button_pressed"))


func _on_button_pressed(button: BaseButton) -> void:
	await UiLib.Buttons.button_delay(button)
	match button.name:
		"PLAY":
			GameState.current = GameState.State.PEN
		"CREDITS":
			GameState.current = GameState.State.CREDITS
		"SETTINGS":
			GameState.current = GameState.State.SETTINGS
		"QUIT":
			GameState.current = GameState.State.QUIT
