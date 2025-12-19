@tool
extends Area3D
class_name Wind

@onready var collision_shape: CollisionShape3D = %WindShape
@onready var particles: GPUParticles3D = %WindParticles

@export var area_size: Vector3 = Vector3.ONE:
	set(value):
		area_size = value
		if is_node_ready() || Engine.is_editor_hint():
			_update_shape()

@export var direction: Vector3 = Vector3.LEFT:
	set(value):
		direction = value.normalized()
		if is_node_ready() || Engine.is_editor_hint():
			_update_particles()

@export_range(100.0, 10000.0, 1.0) var strength: float = 100.0:
	set(value):
		strength = value
		if is_node_ready() || Engine.is_editor_hint():
			_update_particles()

@export_range(0.1, 2.0, 0.1) var particle_speed_multiplier: float = 1.0:
	set(value):
		particle_speed_multiplier = value
		if is_node_ready() || Engine.is_editor_hint():
			_update_particles()

func _ready() -> void:
	await get_tree().process_frame
	_update_shape()
	_update_particles()

func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is RigidBody3D:
			body.apply_central_force(direction * strength)

func _update_shape() -> void:
	if collision_shape.shape is BoxShape3D:
		collision_shape.shape.size = area_size

func _update_particles() -> void:
	if not particles:
		return

	var mat := particles.process_material
	if mat is ParticleProcessMaterial:
		# Match emission volume to wind area
		mat.emission_box_extents = area_size * 0.5

		# Push particles in wind direction
		mat.direction = direction
		mat.initial_velocity_min = strength * 0.01
		mat.initial_velocity_max = strength * 0.02

		mat.turbulence_noise_strength = strength * 0.01
