
class_name UiLib
extends Node

class Buttons:
	const on_button_pressed_TIME: float = 0.14


	static func setup_buttons(buttons: ButtonGroup, call_func: Callable) -> void:
		for button: Button in buttons.get_buttons():
			button.mouse_entered.connect(on_button_hoverd)
			button.pressed.connect(on_button_pressed)
		buttons.pressed.connect(call_func)


	static func on_button_hoverd() -> void:
		GlobalAudioPlayer.playlist["UI"]["Hover"].play()


	static func on_button_pressed() -> void:
		GlobalAudioPlayer.playlist["UI"]["Click1"].play()

	## A minor flourish
	static func button_delay(button: Button) -> void:
		await Engine.get_main_loop().create_timer(on_button_pressed_TIME).timeout
		button.button_pressed = false
