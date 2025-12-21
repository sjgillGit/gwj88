extends MeshInstance3D

func _ready():
	get_parent().thrusting_changed.connect(set_thrusting)

var last_pos := Vector3()

func set_thrusting(value: bool):

	%ThrustParticles.emitting = value

func _physics_process(delta: float) -> void:
	var gv := (global_position - last_pos) / delta
	last_pos = global_position
	var velocity := global_basis.inverse() * gv
	var pm := %ThrustParticles.process_material as ParticleProcessMaterial
	pm.initial_velocity_min = -(velocity.y * 0.35) + 3.0
	pm.initial_velocity_max = -(velocity.y * 0.35) + 5.0
	var amount := (-velocity.y / 500.0) if velocity.y else 0.0
	pm.direction = Vector3(0.0, -1.0, clampf(amount, -0.4, 0.0)).normalized()
