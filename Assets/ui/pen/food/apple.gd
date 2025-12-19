extends StaticBody3D

signal ate_apple


func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Ate apple!")
			ate_apple.emit()
			queue_free()
