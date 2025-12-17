extends Area3D
class_name Boost

@export var direction: Vector3 = Vector3.FORWARD
@export var strength: float = 1000

func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is RigidBody3D:
			body.apply_central_force(direction * strength)
