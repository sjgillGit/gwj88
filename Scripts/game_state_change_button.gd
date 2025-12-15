extends Button

@export var state: GameState.State

func _ready() -> void:
	pressed.connect(func():
		GameState.current_state = state
	)
