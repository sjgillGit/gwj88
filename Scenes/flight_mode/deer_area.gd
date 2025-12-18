class_name DeerArea
extends Area3D

## inherit from this script to make an area the deer can see...

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body is DeerMissile:
		body.add_area(self)


func _on_body_exited(body: Node3D) -> void:
	if body is DeerMissile:
		body.remove_area(self)


# Virtual
func apply_physics(state: PhysicsDirectBodyState3D, mass: float):
	pass
