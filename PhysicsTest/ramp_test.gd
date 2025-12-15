extends Node3D

var _player: Node3D

func _ready():
	_set_launch_mode(%LaunchCheckButton.button_pressed)


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


func _set_launch_mode(launch_mode: bool):
	if _player:
		_player.free()
	if launch_mode:
		_player = preload("res://PhysicsTest/deer.tscn").instantiate()
		_player.distance_updated.connect(_on_distance_updated)
	else:
		_player = preload("res://Scenes/player.tscn").instantiate()
	add_child(_player)
	if 'show_debug_ui' in _player:
		_player.show_debug_ui = false
	_player.global_transform = %DeerEmitter.global_transform
	var cams := _player.find_children("*", "Camera3D")
	if len(cams):
		cams[0].current = true
	_find_cams()


func _on_distance_updated():
	if _player is DeerMissile:
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




func _on_launch_check_button_toggled(toggled_on: bool) -> void:
	_set_launch_mode(toggled_on)
	%LaunchCheckButton.release_focus()


func _on_timer_timeout() -> void:
	if _player is DeerMissile:
		_on_distance_updated()
