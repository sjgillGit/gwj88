extends Node

signal state_changed(next_state: State)

enum State { STARTUP, MAIN_MENU, PLAY, QUIT }

var current_state: State = State.STARTUP:
	set(v):
		current_state = v
		state_changed.emit(current_state)
		if current_state == State.QUIT:
			get_tree().quit()
