extends Node3D

func _ready():
	var cams := find_children("*", "Camera3D", true, false)
	var co := %CameraOption as OptionButton
	for c: Camera3D in cams:
		var i := co.item_count
		co.add_item(c.name)
		co.set_item_metadata(i, c.get_instance_id())
		if c.is_current():
			co.select(i)


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


func _on_deer_button_pressed() -> void:
	var deer := %DeerPhysicsTest as RigidBody3D
	deer.angular_velocity = Vector3()
	deer.linear_velocity = Vector3()
	deer.global_transform = %DeerEmitter.global_transform
