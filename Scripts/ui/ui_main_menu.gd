class_name UiMainMenu
extends Control


func _on_play_button_pressed():
	GameState.current = GameState.State.PEN


func _on_credits_button_pressed():
	GameState.current = GameState.State.CREDITS


func _on_settings_button_pressed():
	GameState.current = GameState.State.SETTINGS


func _on_quit_button_pressed():
	GameState.current = GameState.State.QUIT
