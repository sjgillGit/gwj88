
# class_name GameState
extends Node

signal new_state(new_state: State, old_state: State)

enum State{
	STARTUP, ## Initial mode, always points to MAIN_MENU once done.
	MAIN_MENU, ## Launching point
	SETTINGS, ## Should mirror the structure of the first scene
	CREDITS, ## Whatever we may come up with
	PLAY, ## Should point to the scene created by the 3D team
	PEN, ## Upgrades screen
	QUIT, ## Should just auto close the game
	PAUSE, ## TODO
	}

var current: State:
	set(v):
		print(State.find_key(v))
		if v == State.QUIT:
			get_tree().quit()
		new_state.emit(v, current)
		current = v

## This exists only for Dev purposes. We can peel this off later on
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		current = State.PAUSE
