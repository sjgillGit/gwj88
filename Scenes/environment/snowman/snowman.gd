extends StaticBody3D

const SNOWBALL = preload("uid://dsovid6f4r4ca")

@onready var marker_3d: Marker3D = $Marker3D
@onready var timer: Timer = $Timer

@export var projectile_speed: float = 300
@export var shot_delay: float = 6
@export var snowball_container: Node3D

var target: RigidBody3D
var gravity: float = 0#9.8

func _ready() -> void:
	assert(snowball_container != null, "ERROR: snowball_container must be set. %s" % get_path())

func _on_area_3d_body_entered(body: Node3D) -> void:
	target = body
	timer.start(shot_delay)

func _on_timer_timeout() -> void:
	var aim := CalculateIntercept(target.global_position, target.linear_velocity, marker_3d.global_position, projectile_speed + randf_range(-40, 40))
	var accuracy = PI/500
	aim = aim + Vector3(randf_range(-accuracy, accuracy), randf_range(-accuracy, accuracy), 0)
	
	var projectile: Node3D = SNOWBALL.instantiate()
	projectile.target = target
	projectile.global_position = marker_3d.global_position
	snowball_container.add_child(projectile)
	projectile.init(projectile_speed, aim)
	if target.has_method("trigger_snowball_qte"):
		target.trigger_snowball_qte(projectile)

static func CalculateIntercept(targetLocation: Vector3, targetVelocity: Vector3, interceptorLocation: Vector3, interceptorSpeed: float) -> Vector3:
	var Ax: float = targetLocation.x
	var Ay: float = targetLocation.y
	var Az: float = targetLocation.z

	var As: float = targetVelocity.length()
	targetVelocity = targetVelocity.normalized()
	var Av: Vector3 = targetVelocity
	var Avx: float = Av.x
	var Avy: float = Av.y
	var Avz: float = Av.z

	var Bx: float = interceptorLocation.x
	var By: float = interceptorLocation.y
	var Bz: float = interceptorLocation.z

	var Bs: float = interceptorSpeed

	var t: float = 0

	var a: float = (
		pow(As, 2.0) * pow(Avx, 2.0) +
		pow(As, 2.0) * pow(Avy, 2.0) +
		pow(As, 2.0) * pow(Avz, 2.0) -
		pow(Bs, 2.0)
		)

	if a == 0:
		# Debug.Log("Quadratic formula not applicable")
		# print_debug("Quadratic formula not applicable")
		return targetLocation

	var b: float = (
		As * Avx * Ax +
		As * Avy * Ay +
		As * Avz * Az +
		As * Avx * Bx +
		As * Avy * By +
		As * Avz * Bz
		)

	var c: float = (
		pow(Ax, 2.0) +
		pow(Ay, 2.0) +
		pow(Az, 2.0) -
		Ax * Bx -
		Ay * By -
		Az * Bz +
		pow(Bx, 2.0) +
		pow(By, 2.0) +
		pow(Bz, 2.0)
		)

	var t1: float = (-b + pow((pow(b, 2.0) - (4.0 * a * c)), (1.0 / 2.0))) / (2.0 * a)
	var t2: float = (-b - pow((pow(b, 2.0) - (4.0 * a * c)), (1.0 / 2.0))) / (2.0 * a)

	# Debug.Log("t1 = " + t1 + " t2 = " + t2)
	# print_debug("t1 = ", t1, " t2 = ", t2)

	if t1 <= 0 || t1 == INF || is_nan((t1)):
		if t2 <= 0 || t2 == INF || is_nan(t2):
			return targetLocation
		else:
			t = t2
	elif t2 <= 0 || t2 == INF || is_nan(t2) || t2 > t1:
		t = t1
	else:
		t = t2

	# Debug.Log("t = " + t)
	# Debug.Log("Bs = " + Bs)
	# print_debug("t = ", t)
	# print_debug("Bs = ", Bs)

	var bst = (t * pow(Bs, 2.0))

	#var Bvx: float = (Ax - Bx + (t * As + Avx)) / bst
	#var Bvy: float = (Ay - By + (t * As + Avy)) / bst
	#var Bvz: float = (Az - Bz + (t * As + Avz)) / bst
	var Bvx: float = (Ax - Bx + (t * As * Avx)) / bst
	var Bvy: float = (Ay - By + (t * As * Avy)) / bst
	var Bvz: float = (Az - Bz + (t * As * Avz)) / bst

	var Bv: Vector3 = Vector3(Bvx, Bvy, Bvz)

	# Debug.Log("||Bv|| = (Should be 1) " + Bv.magnitude)
	# print_debug("||Bv|| = (Should be 1) ", Bv.length())

	return Bv * Bs
