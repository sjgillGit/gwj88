class_name UiPlay
extends Control

@onready var flight_money_label = %FlightMoney
@onready var roll_money_label = %RollMoney
@onready var main_v_box = %MainVBox

var orig_flight_money_label_text: String
var orig_roll_money_label_text: String

const FlightState = preload("res://Scripts/flight_state.gd").FlightState

var flight_state: FlightState = FlightState.PRE_FLIGHT:
	set(value):
		flight_state = value
		main_v_box.visible = flight_state == FlightState.POST_FLIGHT

var flight_money: int:
	set(v):
		flight_money_label.text = orig_flight_money_label_text.replace(
			"{0}",
			str(v)
		)
		flight_money = v

var roll_money: int:
	set(v):
		roll_money_label.text = orig_roll_money_label_text.replace(
			"{0}",
			str(v)
		)
		roll_money = v


func _ready():
	visibility_changed.connect(_visibility_changed)
	orig_flight_money_label_text = flight_money_label.text
	orig_roll_money_label_text = roll_money_label.text


func _visibility_changed():
	# invoke setter
	flight_state = flight_state


func _on_button_pressed() -> void:
	GameState.current = GameState.State.PEN
