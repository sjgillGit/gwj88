
class_name UiRootNode
extends Control

@onready var main_menu: UiMainMenu = $UiMainMenu
@onready var credits: UiCredits = $UiCredits
@onready var pause: UiPause = $UiPause
@onready var pen: Control = $UiPen
@onready var play: Control = $UiPlay
@onready var settings: Control = $UiSettings
@onready var startup: Control = $UiStartup

func _ready() -> void:
	GameState.new_state.connect(_on_new_state)
	GameState.current = GameState.current # This ensures the Main Menu appears

func _on_new_state(next_state: GameState.State, _old_state: GameState.State) -> void:
	for child: Node in get_children():
		child.hide()
	match next_state:
		GameState.State.STARTUP:    startup.show()
		GameState.State.MAIN_MENU:  main_menu.show()
		GameState.State.SETTINGS:   settings.show()
		GameState.State.CREDITS:    credits.show()
		GameState.State.PLAY:       play.show()
		GameState.State.PEN:        pen.show()
		GameState.State.PAUSE:      pause.show()
		GameState.State.QUIT:       print_debug("This should not have been called")
