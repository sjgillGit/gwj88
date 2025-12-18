
class_name UiRootNode
extends Control

static var instance: UiRootNode

@onready var main_menu: UiMainMenu = $UiMainMenu
@onready var credits: UiCredits = $UiCredits
@onready var pause: UiPause = $UiPause
@onready var pen: UiPen = $UiPen
@onready var play: Control = $UiPlay
@onready var settings: UiSettings = $UiSettings
@onready var startup: UiStartup = $UiStartup


func _ready() -> void:
	assert(!instance, "There can be only one!")
	instance = self
	GameState.new_state.connect(_on_new_state)
	GameState.current = GameState.current # This ensures the Main Menu appears


func _on_new_state(next_state: GameState.State, _old_state: GameState.State) -> void:
	for child: Node in get_children():
		child.hide()
	var menu: Control = get_menu_for_state(next_state)
	if menu:
		menu.show()


func get_menu_for_state(state: GameState.State) -> Control:
	match state:
		GameState.State.STARTUP:    return startup
		GameState.State.MAIN_MENU:  return main_menu
		GameState.State.SETTINGS:   return settings
		GameState.State.CREDITS:    return credits
		GameState.State.PLAY:       return play
		GameState.State.PEN:        return pen
		GameState.State.PAUSE:      return pause
		GameState.State.QUIT:       print_debug("This should not have been called")
	return null
