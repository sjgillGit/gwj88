extends CharacterBody3D

const _SPEED := 200
const _GRAVITY := 140

var _direction := Vector3.ZERO
var _movement := Movement.RUNNING
var _can_move := true

var _max_fly_distance: float
var _fly_starting_position: float

enum Movement {RUNNING, FLYING}


func _ready() -> void:
	# TODO: calculate this dynamically
	_max_fly_distance = 1000.


func _physics_process(_delta: float) -> void:
	# TODO: refactor when falling properly implemented
	if not _can_move:
		return

	if _direction != Vector3.ZERO:
		_direction.normalized()

	velocity = _direction * _SPEED
	velocity += Vector3.DOWN * _GRAVITY
	if _movement == Movement.FLYING:
		velocity += Vector3.FORWARD * _SPEED
	move_and_slide()

	if abs(position.z - _fly_starting_position) >= _max_fly_distance:
		_can_move = false
		return

	if not is_on_floor() and _movement == Movement.RUNNING:
		_movement = Movement.FLYING
		motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		_fly_starting_position = position.z
	elif is_on_floor() and _movement == Movement.FLYING:
		_movement = Movement.RUNNING
		motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED


func _unhandled_key_input(_event: InputEvent) -> void:
	_direction = Vector3.ZERO

	if Input.is_action_pressed("move_left"):
		_direction += Vector3.LEFT

	if Input.is_action_pressed("move_right"):
		_direction += Vector3.RIGHT
	
	if Input.is_action_pressed("move_up"):
		if _movement == Movement.RUNNING:
			_direction += Vector3.FORWARD
		else:
			_direction += Vector3.UP
