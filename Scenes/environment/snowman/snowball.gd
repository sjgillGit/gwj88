class_name Snowball
extends CharacterBody3D

@onready var gpu_particles_3d: GPUParticles3D = $SnowParticles
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@export var mass: float = 5
@export var speed: float = 100.0
@onready var size: float = $CollisionShape3D.shape.radius * 2.0
var target: Node3D
var deflected := false
var collided := false

func init(exclusion: PhysicsBody3D, p_speed: float, dir: Vector3) -> void:
	add_collision_exception_with(exclusion)
	speed = p_speed
	velocity = dir * speed

func _physics_process(_delta: float) -> void:
	if collided:
		return
	var old_velocity := velocity
	move_and_slide()
	for idx in get_slide_collision_count():
		var collision := get_slide_collision(idx)
		var body = collision.get_collider()
		if body is RigidBody3D:
			collision_layer = 0
			collision_mask = 0
			if !deflected:
				var impulse := (-collision.get_normal() * 0.25 + old_velocity.normalized() * 0.75) * velocity.length() * mass
				body.apply_impulse(impulse)
		collided = true
		if target:
			target.remove_snowball(self)
		_break_animation(old_velocity)

func deflect() -> void:
	deflected = true

func _break_animation(v: Vector3) -> void:
	if mesh_instance_3d.visible:
		$AudioStreamPlayerHit.play()
		$AudioStreamPlayerWhistle.stop()
		var mat := gpu_particles_3d.process_material as ParticleProcessMaterial
		mat.direction = v.normalized()
		gpu_particles_3d.restart()
		mesh_instance_3d.hide()


func _on_snow_particles_finished() -> void:
	queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is RigidBody3D && deflected:
		_break_animation(velocity)
