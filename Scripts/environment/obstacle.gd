extends Area3D
class_name Obstacle

@onready var particles: GPUParticles3D = %Particles
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export_range(5.0, 100.0, 5.0) var speed_damp := 10.0

func _ready():
	particles.finished.connect(_on_particles_finished)
	pass
	#texture = texture

func apply_physics(state: PhysicsDirectBodyState3D, mass: float):
	var desired_velocity: Vector3 = state.linear_velocity * -speed_damp
	state.apply_central_force(desired_velocity * mass)

func _on_body_entered(body: Node3D) -> void:
	if body is DeerMissile:
		body.add_area(self)
	animation_player.play("explode")

func _on_body_exited(body: Node3D) -> void:
	if body is DeerMissile:
		body.remove_area(self)

func _on_particles_finished() -> void:
	queue_free()
