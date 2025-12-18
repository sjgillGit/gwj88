@tool
class_name Booster
extends Area3D

# @export var texture: Texture2D:
# 	set(value):
# 		texture = value
# 		if is_node_ready():
# 			$Decal.texture_albedo = texture
@export_range(0.0, 10.0, 0.25) var speed_boost := 2.0

func _ready():
	pass
	#texture = texture

func apply_physics(state: PhysicsDirectBodyState3D, mass: float):
	var desired_velocity: Vector3 = state.linear_velocity * speed_boost
	state.apply_central_force(desired_velocity * mass)

func _on_body_entered(body: Node3D) -> void:
	if body is DeerMissile:
		body.add_area(self)


func _on_body_exited(body: Node3D) -> void:
	if body is DeerMissile:
		body.remove_area(self)
