extends CharacterBody3D

@export var speed: float = 100
var target: Node3D

func init(speed: float, dir: Vector3) -> void:
	self.speed = speed
	velocity = dir * speed

func _physics_process(_delta: float) -> void:
	if target:
		look_at(target.global_position)
		velocity = -basis.z * speed
	move_and_slide()
	for idx in get_slide_collision_count():
		var collision = get_slide_collision(idx)
		print(collision)
		queue_free()
