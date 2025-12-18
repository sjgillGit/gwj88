@tool
class_name Booster
extends DeerArea

@export var texture: Texture2D:
	set(value):
		texture = value
		if is_node_ready():
			$Decal.texture_albedo = texture
@export var speed_boost := 2.0

func _ready():
	super._ready()
	texture = texture

func apply_physics(state: PhysicsDirectBodyState3D, mass: float):
	var desired_velocity: Vector3 = state.linear_velocity * speed_boost
	state.apply_central_force(desired_velocity * mass)
