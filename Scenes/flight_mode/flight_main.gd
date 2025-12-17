extends Node3D

const FlightState = preload("res://Scripts/flight_state.gd").FlightState

var _player: DeerMissile

func _ready():
	_spawn_deer()


func _find_cams():
	var cams := find_children("*", "Camera3D", true, false)
	var co := %CameraOption as OptionButton
	co.clear()
	for c: Camera3D in cams:
		var i := co.item_count
		co.add_item(c.name)
		co.set_item_metadata(i, c.get_instance_id())
		if c.is_current():
			co.select(i)


func _spawn_deer():
	if _player:
		await get_tree().process_frame
		_player.free()
	_player = preload("./deer_missile.tscn").instantiate()
	_player.distance_updated.connect(_on_distance_updated)
	_player.flight_state_changed.connect(_on_flight_state_changed)
	add_child(_player)
	_player.show_debug_ui = false
	_player.global_transform = %DeerEmitter.global_transform
	var cams := _player.find_children("*", "Camera3D")
	if len(cams):
		cams[0].current = true
	_find_cams()
	var menu := _get_menu()
	if menu:
		menu.flight_state = UiPlay.FlightState.PRE_FLIGHT


func _get_menu() -> UiPlay:
	if !UiRootNode.instance:
		return null
	return UiRootNode.instance.get_menu_for_state(GameState.State.PLAY)


func _on_distance_updated():
	# TODO: update flight menu ui here?
	%FlightStats.text = "\n".join([
		_player.speed_str,
		_player.flight_distance_str,
		_player.roll_distance_str
	])


func _on_ice_cube_button_pressed() -> void:
	var cube := %IceCube.duplicate() as RigidBody3D
	cube.transform = Transform3D()
	cube.linear_velocity = Vector3()
	cube.angular_velocity = Vector3()
	%IceCubeEmitter.add_child(cube)


func _on_camera_option_item_selected(index: int) -> void:
	if index >= 0:
		var co := %CameraOption as OptionButton
		var c := instance_from_id(co.get_item_metadata(index)) as Camera3D
		if c:
			c.current = true


func _on_flight_state_changed(flight_state: FlightState):
	var menu := _get_menu()
	if menu:
		menu.flight_state = flight_state
	elif flight_state == FlightState.POST_FLIGHT:
		# if we are debugging the scene, just restart
		_spawn_deer()


func _on_timer_timeout() -> void:
	_on_distance_updated()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_flight_state_changed(FlightState.POST_FLIGHT)
