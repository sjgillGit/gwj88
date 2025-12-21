class_name UiMainMenu
extends Control


func _on_play_button_pressed() -> void:
	GameState.current = GameState.State.PEN


func _on_credits_button_pressed() -> void:
	GameState.current = GameState.State.CREDITS


func _on_settings_button_pressed() -> void:
	GameState.current = GameState.State.SETTINGS


func _on_quit_button_pressed() -> void:
	GameState.current = GameState.State.QUIT


# TODO: Bring camera back to origin when Main Menu is selected.


func _on_option_button_mouse_entered() -> void:

	$OptionButton.clear()
	$OptionButton.modulate = Color.WHITE
	$OptionButton.add_item("-", 0)
	$OptionButton.add_item("1", GameState.State.ENDING_WIN)
	$OptionButton.add_item("2", GameState.State.ENDING_SPACE)
	$OptionButton.add_item("3", GameState.State.ENDING_HOLE)
	$OptionButton.add_item("4", GameState.State.ENDING_BEACH)


func _on_option_button_mouse_exited() -> void:
	$OptionButton.modulate = Color(0,0,0,0.2)


func _on_option_button_item_selected(index: int) -> void:
	if index > -1:
		var id := $OptionButton.get_item_id(index) as GameState.State
		if id > 0:
			GameState.current = id
