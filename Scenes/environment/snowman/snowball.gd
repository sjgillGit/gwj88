class_name Snowball
extends CharacterBody3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@export var speed: float = 100
var target: Node3D
var parried: bool = false

func init(speed: float, dir: Vector3) -> void:
	self.speed = speed
	velocity = dir * speed

func _physics_process(_delta: float) -> void:
	move_and_slide()
	for idx in get_slide_collision_count():
		var collision := get_slide_collision(idx)
		var body = collision.get_collider()
		if body is RigidBody3D:
			body.apply_impulse(-collision.get_normal() * 100)
		gpu_particles_3d.restart()
		mesh_instance_3d.hide()
		_break_animation()

func parry() -> void:
	parried = true
	collision_layer = 0
	collision_mask = 0
	_break_animation()

func _break_animation() -> void:
	gpu_particles_3d.restart()
	mesh_instance_3d.hide()

func _on_gpu_particles_3d_finished() -> void:
	if target:
		target.remove_snowball(self)
	queue_free()
