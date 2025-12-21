extends StaticBody3D

const SNOWBALL = preload("uid://dsovid6f4r4ca")

@onready var marker_3d: Marker3D = $Marker3D
@onready var timer: Timer = $Timer

@export var projectile_speed: float = 20
@export var shot_delay: float = 0.1
@export var snowball_container: Node3D

var target: RigidBody3D
var gravity: float = 0#9.8

func _ready() -> void:
	assert(snowball_container != null, "ERROR: snowball_container must be set. %s" % get_path())

func _on_area_3d_body_entered(body: Node3D) -> void:
	target = body
	timer.start(shot_delay)

func _on_timer_timeout() -> void:
	#var aim := PredictiveTargeting.PredictiveAim(marker_3d.global_position, projectile_speed, target.global_position, target.linear_velocity, gravity)
	var aim := PredictiveTargeting.CalculateIntercept(target.global_position, target.linear_velocity, marker_3d.global_position, projectile_speed)
	#if not aim:
		#return
	var projectile: Node3D = SNOWBALL.instantiate()
	# projectile.target = target
	projectile.global_position = marker_3d.global_position
	snowball_container.add_child(projectile)
	# projectile.speed = projectile_speed
	projectile.init(projectile_speed, aim)
