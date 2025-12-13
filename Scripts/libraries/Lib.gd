
class_name Lib
extends Node

class Buttons:
	static func name_them(buttons: ButtonGroup) -> void:
		for button in buttons.get_buttons():
			button.text = button.name
