class_name UiPlay
extends Control

const FlightState = preload("res://Scripts/flight_state.gd").FlightState

var flight_state: FlightState = FlightState.PRE_FLIGHT:
	set(value):
		flight_state = value
		$Button.visible = flight_state == FlightState.POST_FLIGHT


func _ready():
	visibility_changed.connect(_visibility_changed)


func _visibility_changed():
	# invoke setter
	flight_state = flight_state


func _on_button_pressed() -> void:
	GameState.current = GameState.State.PEN
