extends Control

@onready var startup: Control = %Startup
@onready var main_menu: Control = %MainMenu


func _ready() -> void:
	GameState.state_changed.connect(_on_game_state_changed)
	startup.show()


func _on_game_state_changed(state: GameState.State):
	for child in get_children():
		child.hide()
	match state:
		GameState.State.STARTUP:
			startup.show()
		GameState.State.MAIN_MENU:
			main_menu.show()
		GameState.State.PLAY:
			pass
