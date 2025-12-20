@tool
extends DeerArea
class_name Wind

@onready var collision_shape: CollisionShape3D = %WindShape
@onready var particles: GPUParticles3D = %WindParticles
@onready var snow_particles: GPUParticles3D = %SnowParticles
@onready var cloud_particles: GPUParticles3D = %CloudParticles

@export var area_size: Vector3 = Vector3.ONE:
	set(value):
		area_size = value
		if is_node_ready():
			_update_shape()

@export var direction: Vector3 = Vector3.BACK:
	set(value):
		direction = value.normalized()
		if is_node_ready():
			_update_particles()

@export_range(0.0, 10000.0, 1.0) var strength: float = 100.0:
	set(value):
		strength = value
		if is_node_ready():
			_update_particles()

@export_range(0.1, 2.0, 0.1) var particle_speed_multiplier: float = 10.0:
	set(value):
		particle_speed_multiplier = value
		if is_node_ready():
			_update_particles()

func _ready() -> void:
	area_size = area_size
	direction = direction
	strength = strength
	particle_speed_multiplier = particle_speed_multiplier
	if RenderingServer.get_current_rendering_method() != "forward_plus":
		cloud_particles.visible = true
		cloud_particles.emitting = true
	super()


func get_global_wind_direction():
	return direction * global_transform.basis


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is RigidBody3D:
			body.apply_central_force(global_basis * direction * strength * body.mass)
			if body is DeerMissile:
				for p in [particles, snow_particles]:
					p.global_position = body.global_position + body.linear_velocity.clampf(-25, 25)
					p.global_position = body.global_position + body.linear_velocity.clampf(-25, 25)


func _update_shape() -> void:
	if collision_shape.shape is BoxShape3D:
		collision_shape.shape.size = area_size
	$FogVolume.size = area_size


func _update_particles() -> void:
	if not particles:
		return
	snow_particles.amount_ratio = clampf(0.10 + strength / 100.0, 0.0, 1.0)
	for p: GPUParticles3D in [particles, snow_particles]:
		var mat := p.process_material
		# Match emission volume to wind area

		# Push particles in wind direction
		mat.direction = direction
		var multiplier := (2.0 if p == particles else 1.0) * particle_speed_multiplier
		mat.initial_velocity_min = strength * multiplier
		mat.initial_velocity_max = strength * multiplier * 2

		mat.turbulence_noise_strength = strength * 10
	_reset_particle_sizes()


func _reset_particle_sizes():
	var aabb := AABB(Vector3(), Vector3())
	aabb = aabb.expand(area_size)
	aabb = aabb.expand(area_size * -1)
	var cloud_mesh := cloud_particles.draw_pass_1 as QuadMesh
	cloud_mesh.size = Vector2.ONE * area_size.length() * 0.2

	for p: GPUParticles3D in [particles, snow_particles, cloud_particles]:
		p.visibility_aabb = aabb
		var mat := p.process_material as ParticleProcessMaterial
		mat.emission_box_extents = area_size * 0.5


func _on_body_entered(body: Node3D) -> void:
	super(body)
	var emit_size = 25
	if body is DeerMissile:
		for p in [particles, snow_particles]:
			p.visibility_aabb = AABB(Vector3.ONE * -emit_size * 2, Vector3.ONE * emit_size * 4)
			var mat := p.process_material as ParticleProcessMaterial
			mat.emission_box_extents = Vector3.ONE * emit_size


func _on_body_exited(body: Node3D) -> void:
	super(body)
	if !get_overlapping_bodies().any(func(b): return b is DeerMissile):
		_reset_particle_sizes()
