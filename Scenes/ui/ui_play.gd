class_name UiPlay
extends Control

@onready var flight_money_label = %FlightMoney
@onready var roll_money_label = %RollMoney

var orig_flight_money_label_text: String
var orig_roll_money_label_text: String

var completion_percent: float:
	set(v):
		completion_percent = v
		if is_node_ready():
			var dt:Control = %DeerThumb
			var dtp:Control = dt.get_parent()
			var max_pos: float = dtp.size.x - dt.size.x

			%DeerThumb.position.x = clampf(completion_percent, 0.0, 1.0) * max_pos

var flight_speed: float:
	set(v):
		flight_speed = v
		if is_node_ready():
			%FlightSpeedMeter.value = flight_speed


const FlightState = preload("res://Scripts/flight_state.gd").FlightState

var flight_state: FlightState = FlightState.PRE_FLIGHT:
	set(value):
		flight_state = value

		%EndBox.visible = flight_state == FlightState.POST_FLIGHT
		var tween_duration := 0.5
		var f_ui := %FlightUI as Control
		match flight_state:
			FlightState.PRE_FLIGHT:
				f_ui.modulate = Color.TRANSPARENT
			FlightState.FLIGHT:
				f_ui.pivot_offset = f_ui.size * tween_duration
				f_ui.scale = Vector2.ONE * 3.0
				create_tween().tween_property(f_ui, "modulate", Color.WHITE, tween_duration)
				create_tween().tween_property(f_ui, "scale", Vector2.ONE, tween_duration)
			_:
				create_tween().tween_property(f_ui, "modulate", Color.TRANSPARENT, 0.5)
				create_tween().tween_property(f_ui, "scale", Vector2.ONE * 3.0, tween_duration)


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

var coin_money: int:
	set(v):
		coin_money = v
		%CoinMoney.format([v])


func _ready():
	visibility_changed.connect(_visibility_changed)
	orig_flight_money_label_text = flight_money_label.text
	orig_roll_money_label_text = roll_money_label.text
	GameStats.money_changed.connect(_on_money_changed)


func _on_money_changed():
	%TotalMoney.format([GameStats.money])


func _visibility_changed():
	# invoke setter
	if visible:
		flight_state = flight_state


func _on_button_pressed() -> void:
	%EndBox.hide()
	GameState.current = GameState.State.PEN


func _on_button_2_pressed() -> void:
	%EndBox.hide()
	GameState.current = GameState.State.REPLAY


func _on_main_box_visibility_changed() -> void:
	if %EndBox.visible && visible:
		%Button.grab_focus()
