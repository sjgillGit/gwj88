extends CharacterBody3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@export var speed: float = 100
var target: Node3D

func init(speed: float, dir: Vector3) -> void:
	self.speed = speed
	velocity = dir * speed

func _physics_process(_delta: float) -> void:
	if target:
		look_at(target.global_position)
		velocity = lerp(velocity, -basis.z * speed, 0.2)
	move_and_slide()
	for idx in get_slide_collision_count():
		var collision = get_slide_collision(idx)
		gpu_particles_3d.restart()
		mesh_instance_3d.hide()
		await get_tree().create_timer(3).timeout
		queue_free()


func _on_area_3d_body_entered(bodwdy: Node3D) -> void:
	pass
	#target = body
