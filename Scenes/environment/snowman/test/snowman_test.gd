extends Node3D

const FlightState := preload("res://Scripts/flight_state.gd").FlightState
var seconds := 0.0

func _ready():
	Engine.time_scale = 1.0
	await get_tree().process_frame
	$DeerMissile._flight_state_changed(FlightState.FLIGHT)
	$DeerMissile.linear_velocity = Vector3.MODEL_FRONT * 50.0
	var upgrades: Array[DeerUpgrades.Category]
	upgrades.assign([DeerUpgrades.Category.SMALL_ANTLERS])
	$DeerMissile.set_enabled_upgrades(upgrades)
	$Timer.wait_time = $Snowman.shot_delay * 0.8
	$Timer.start()
	await get_tree().create_timer($Snowman.shot_delay * 0.1)
	$Snowman._on_timer_timeout()


func _on_timer_timeout() -> void:
	$Timer.wait_time = $Snowman.shot_delay
	$DeerMissile.linear_velocity = Vector3.MODEL_FRONT * 50.0
	$DeerMissile.angular_velocity = Vector3.ZERO
	$DeerMissile.global_transform = $DeerMissileStart.global_transform

func _process(_delta):
	seconds += _delta
	$Label.text = "%s\n%s" % [
		seconds,
		$DeerMissile._stats.get("snowball", "")
	]
	var pred_pos = $DeerMissile._stats.get("snowball_pos", {})
	if pred_pos:
		$SPredPos.global_position = pred_pos.s
		$DPredPos.global_position = pred_pos.d


func _on_h_slider_value_changed(value: float) -> void:
	$Snowman.global_position.z = value
	$Camera3D.size = value * (2.5/3.0)
	$Camera3D.global_position.z = ($DeerMissileStart.global_position.z + $Snowman.global_position.z) * 0.75
