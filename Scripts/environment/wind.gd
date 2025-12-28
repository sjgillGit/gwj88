@tool
extends DeerArea
class_name Wind

@onready var collision_shape: CollisionShape3D = %CollisionShape3D
@onready var particles: GPUParticles3D = %WindParticles
@onready var snow_particles: GPUParticles3D = %SnowParticles
@onready var cloud_particles: GPUParticles3D = %CloudParticles
@onready var cloud_particles2: GPUParticles3D = %CloudParticles2
@export_tool_button("Reset Clouds") var reset_clouds := _reset_clouds
@export var area_size: Vector3 = Vector3.ONE:
	set(value):
		area_size = value
		if is_node_ready():
			_update_shape()
			_update_particles()

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
			_update_audio()

var _cloud_layer_num := 0

static var disable_cloud_alpha := false
static var last_layer_num := 0

func _ready() -> void:
	if !Engine.is_editor_hint():
		$SampleGPUParticlesAttractorVectorField3D.queue_free()
	area_size = area_size
	direction = direction
	strength = strength
	cloud_particles.visible = true
	cloud_particles.emitting = true
	super()
	_update_cloud_alpha()
	_cloud_layer_num = last_layer_num
	last_layer_num = (last_layer_num + 1) % 32

func _reset_clouds():
	print("Clouds reset")
	cloud_particles.restart()

## direction of wind, unit vector
func get_global_wind_direction():
	return direction * global_transform.basis


## strength of wind (with holiday spirit modifier)
func get_wind_strength_w_hs(holiday_spirit: float):
	return strength * _get_hs_mod(holiday_spirit)


func _get_hs_mod(holiday_spirit: float):
	var hs_mod := 1.0
	if holiday_spirit >= 2.0:
		hs_mod = 0.01
	elif holiday_spirit >= 1.0:
		hs_mod = -0.2
	return hs_mod


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		var hs_mod := 1.0
		var hs_brightness := 0.5
		if body is RigidBody3D:
			var dm := body as DeerMissile
			if dm:
				var hs :float= dm.get_holiday_spirit()
				hs_mod = _get_hs_mod(hs)
				if hs > 1:
					hs_brightness = 0.75
				elif hs > 0:
					hs_brightness = 1.0
				_update_particles(hs_mod)
			body.apply_central_force(global_basis * direction * hs_mod * strength * body.mass)

		var mat := cloud_particles.draw_pass_1.material as StandardMaterial3D
		mat.albedo_color = Color(hs_brightness, hs_brightness, hs_brightness, mat.albedo_color.a)


func _update_shape() -> void:
	if collision_shape.shape is BoxShape3D:
		collision_shape.shape.size = area_size
	$FogVolume.size = area_size


func _update_audio() -> void:
	var volume := -(20.0 - clampf(strength, 0.0, 20.0))
	var pitch_scale := clampf(strength / 10, 0.8, 1.5) + randf_range(-0.1, 0.1)
	$AudioStreamPlayer3D.pitch_scale = pitch_scale
	$AudioStreamPlayer3D.volume_db = volume
	# average of all three sides.. I guess we should try to make them squarish in the editor
	$AudioStreamPlayer3D.max_distance = (area_size.length() / 3.0) * 1.5

func _update_particles(hs_mod := 1.0) -> void:
	if not particles:
		return
	var ratio := clampf(area_size.length() / 300.0 + 0.1, 0.25, 1.0)
	var strength_percent := minf((strength + 50.0) / 150.0, 1.0)

	for cp in [cloud_particles, cloud_particles2]:
		var cp_mat := cp.draw_pass_1.material as StandardMaterial3D
		assert(cp.draw_pass_1.get_local_scene(), 'Resource must be local to scene: %s' % [cp.draw_pass_1.get_id_for_path(cp.get_path())])
		assert(cp_mat.get_local_scene(), 'Resource must be local to scene: %s' % [cp_mat.get_id_for_path(cp.get_path())])
		cp_mat.albedo_color.a = strength_percent
	snow_particles.amount_ratio = ratio
	particles.amount_ratio = minf(strength_percent * 0.75 + 0.25, 1.0)

	assert(_cloud_layer_num < 32)
	cloud_particles.layers = 1 << _cloud_layer_num
	particles.layers = 1 << _cloud_layer_num
	for cb: GPUParticlesCollisionBox3D in cloud_particles.get_children():
		cb.cull_mask = cloud_particles.layers
	particles.lifetime = (1.0 - strength_percent) * 0.5 + 0.1
	for p: GPUParticles3D in [particles, snow_particles]:
		var mat := p.process_material as ParticleProcessMaterial
		assert(mat.get_local_scene(), 'Resource must be local to scene: %s' % [mat.get_id_for_path(p.get_path())])
		# Match emission volume to wind area

		# Push particles in wind direction
		assert(hs_mod != 0, "hsmod can't be 0")
		mat.direction = (direction * hs_mod).normalized()
		if p == particles:
			mat.initial_velocity_max = strength_percent * 50.0
			mat.initial_velocity_min = strength_percent * 45.0
		elif p == snow_particles:
			mat.initial_velocity_max = strength_percent * 50.0
			mat.initial_velocity_min = strength_percent * 40.0
		else:
			assert(false, 'unknown particle emitter')

		mat.turbulence_noise_strength = strength * 10
	# put these particle emitters on the far side so the snow/wind particles are actually inside the particle box...
	particles.position = -direction * area_size * 0.1
	snow_particles.position = particles.position

	_reset_particle_sizes()


func _reset_particle_sizes():
	var aabb := AABB(Vector3(), Vector3())
	aabb = aabb.expand(area_size)
	aabb = aabb.expand(area_size * -1)
	for cp: GPUParticles3D in [cloud_particles, cloud_particles2]:
		var cloud_mesh := cp.draw_pass_1 as QuadMesh
		cloud_mesh.size = Vector2.ONE * area_size.length() * 0.25
		cp.collision_base_size = area_size[area_size.min_axis_index()] * 0.1
		cp.amount_ratio = minf(0.5, area_size.length() / 100.0) + 0.5
		assert(cloud_mesh.get_local_scene(), 'Resource must be local to scene: %s' % [cloud_mesh.get_id_for_path(cp.get_path())])

	for cb: GPUParticlesCollisionBox3D in cloud_particles.get_children():
		var pos_n := cb.position.normalized()
		cb.position = pos_n * area_size
		var other_axes := (pos_n.abs() * -1.0) + Vector3.ONE
		cb.size = other_axes * area_size * 2.0 + pos_n.abs()

	for p: GPUParticles3D in [particles, snow_particles, cloud_particles, cloud_particles2]:
		p.visibility_aabb = aabb
		var mat := p.process_material as ParticleProcessMaterial
		assert(mat.get_local_scene(), 'Resource must be local to scene: %s' % [mat.get_id_for_path(p.get_path())])
		var modifier := Vector3.ONE
		match p:
			cloud_particles2: modifier = Vector3.ONE
			cloud_particles: modifier = Vector3(0.45, 0.35, 0.45)
			particles: modifier = Vector3.ONE * 0.5
		mat.emission_box_extents = area_size * modifier
		# force reset the amount
		if Engine.is_editor_hint():
			p.restart()


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


func _on_timer_timeout() -> void:
	# alpha clouds half the fps, disable them if we have a low frame rate
	if Engine.get_frames_per_second() < 25 && !Engine.is_editor_hint():
		Wind.disable_cloud_alpha = true
		_update_cloud_alpha()


func _update_cloud_alpha():
	if Wind.disable_cloud_alpha:
		for cp in [cloud_particles, cloud_particles2]:
			cp.draw_order = GPUParticles3D.DRAW_ORDER_INDEX
			var mat := cp.draw_pass_1.material as StandardMaterial3D
			assert(mat.get_local_scene(), 'Resource must be local to scene: %s' % [mat.get_id_for_path(cp.get_path())])
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
