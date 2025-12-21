@tool
extends BoxContainer

@export_multiline var label_text: String:
	set(v):
		label_text = v
		if is_node_ready():
			%Label.text = label_text

func _ready():
	label_text = label_text


func _on_quit_button_pressed() -> void:
	GameState.current = GameState.State.QUIT



func _on_main_menu_button_pressed() -> void:
	GameState.current = GameState.State.MAIN_MENU
