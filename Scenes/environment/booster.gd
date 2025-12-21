@tool
class_name Booster
extends DeerArea

@export var decal_scale := 1.0:
	set(value):
		decal_scale = value
		if is_node_ready():
			$Decal.scale = Vector3.ONE * value

@export var texture: Texture2D:
	set(value):
		texture = value
		if is_node_ready():
			$Decal.visible = !!texture
			$MeshInstance3D.visible = !texture
			$Decal.texture_albedo = texture

@export var add_emission: bool:
	set(value):
		add_emission = value
		if is_node_ready():
			$Decal.texture_emission = texture

## negative boost is a speed penalty. used by the hay piles on the ramp
@export_range(-10.0, 10.0, 0.25) var speed_boost := 2.5


func _ready():
	super._ready()
	texture = texture
	decal_scale = decal_scale
	add_emission = add_emission


func apply_physics(state: PhysicsDirectBodyState3D, mass: float):
	var desired_velocity: Vector3 = state.linear_velocity * speed_boost
	state.apply_central_force(desired_velocity * mass)
