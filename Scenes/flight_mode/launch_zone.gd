class_name LaunchZone
extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body is DeerMissile:
		body.add_area(self)


func _on_body_exited(body: Node3D) -> void:
	if body is DeerMissile:
		body.remove_area(self)
