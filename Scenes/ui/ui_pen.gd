
class_name UiPen
extends Control


func _ready() -> void:
	UiLib.Buttons.setup_buttons(%PLAY.button_group, Callable(self, &"_on_button_pressed"))


func _on_button_pressed(button: Button) -> void:
	match button.name:
		"PLAY":
			GameState.current = GameState.State.PLAY
