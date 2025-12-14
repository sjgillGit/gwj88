
class_name Lib
extends Node

class Buttons:

	const BUTTON_DELAY_TIME: float = 0.14

	static func setup_buttons(buttons: ButtonGroup) -> void:
		for button: Button in buttons.get_buttons():
			button.mouse_entered.connect(on_button_hoverd)
			button.pressed.connect(on_button_pressed)

	static func on_button_hoverd() -> void:
		GlobalAudioPlayer.playlist["UI"]["Hover"].play()

	static func on_button_pressed() -> void:
		GlobalAudioPlayer.playlist["UI"]["Click1"].play()

	static func button_delay() -> void:
		await Engine.get_main_loop().create_timer(BUTTON_DELAY_TIME).timeout
