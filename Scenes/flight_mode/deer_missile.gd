class_name DeerMissile
extends RigidBody3D

signal distance_updated()

# todo: make this lower but let them push forward to move when
# they are on the ramp/platform
@export var base_thrust := 200.0
@export var base_lift := 0.0
@export var base_drag := 1.0
##
@export var base_mass := 50.0
## Amount of control you have over flight.. should be between 0 and 1
@export var base_control := 0.9
## speeds at which we have flight control
@export var control_envelope: Curve

@export var pitch_speed := 100.0
@export var roll_speed := 100.0
@export var yaw_speed := 100.0

@export var show_debug_ui := true:
	set(value):
		if is_node_ready():
			%DebugUi.visible = value

var flight_distance := 0.0
var roll_distance := 0.0

## string versions of these stats
var flight_distance_str := ""
var roll_distance_str := ""
var speed_str := ""

var _launch_point: Vector3
var _impact_point: Vector3

# Update this vector to apply thrust in a specific direction (usually BACK)
var _thrust_vector := Vector3()
var _upgrade_thrust := 0.0
var _upgrade_lift := 0.0
var _upgrade_drag := 0.0
var _upgrade_mass := 0.0
var _upgrade_control := 0.0
var _player_inputs: Vector3
var _on_ramp := true
var _stats := {}
var _landed := false


func _ready():
	# invoke setter!
	if !control_envelope:
		control_envelope = Curve.new()
		control_envelope.add_point(Vector2(0, 0))
		control_envelope.add_point(Vector2(20, 1.0))
		control_envelope.add_point(Vector2(120, 1.0))
		control_envelope.add_point(Vector2(200, 0))
	show_debug_ui = show_debug_ui
	_apply_upgrade_stats()


func _apply_upgrade_stats():
	# TODO: add up stats from current upgrades and save them in `_upgrade_x` vars
	_upgrade_mass = 0 # (no upgrades yet!)
	mass = base_mass + _upgrade_mass


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var _distance_updated := false
	_on_ramp = false
	var cb := get_colliding_bodies()
	for b in cb:
		if b is PhysicalRamp:
			_launch_point = global_position
			_impact_point = Vector3()
			_distance_updated = true
			_on_ramp = true
		elif b is Ground:
			_on_ramp = false
			if !_landed:
				_impact_point = global_position
				_distance_updated = true
			_landed = true
		elif b is TopPlatform:
			_on_ramp = true

	var local_thrust := global_basis * _thrust_vector * (base_thrust + _upgrade_thrust)
	state.apply_central_impulse(local_thrust * state.step)

	_apply_drag(state)
	_apply_lift(state)
	_apply_control(state)

	if _on_ramp:
		# X inputs rotate around the Y axis (yaw) when we aren't flying
		state.apply_torque_impulse(global_basis * (Vector3.BACK * _player_inputs.x * roll_speed * state.step))
	else:
		# X inputs rotate around the Z axis (roll)
		state.apply_torque_impulse(global_basis * (Vector3.BACK * _player_inputs.x * roll_speed * state.step))
	# Y inputs rotate around the X axis (pitch)
	state.apply_torque_impulse(global_basis * (Vector3.LEFT * _player_inputs.y * pitch_speed * state.step))
	# Z inputs rotate around the Y axis (yaw)
	# we don't actually have any inputs for this yet
	state.apply_torque_impulse(global_basis * (Vector3.UP * _player_inputs.z * state.step * yaw_speed))
	if _distance_updated:
		_update_distances()
	_print_stats()
		


func _apply_drag(state: PhysicsDirectBodyState3D):
	var drag_amount := base_drag + _upgrade_drag
	drag_amount *= state.linear_velocity.length()
	var drag_vector := state.linear_velocity.normalized() * -1
	state.apply_central_impulse(state.step * drag_amount * drag_vector)
	_stats.drag = "%.3f" % [drag_amount]
	# higher speed = more drag..


func _apply_lift(state: PhysicsDirectBodyState3D):
	var lift_vector := state.transform.basis * Vector3.UP
	var motion_vector := state.linear_velocity.normalized()
	var forward_vector := state.transform.basis * Vector3.MODEL_FRONT
	var forward_angle := forward_vector.dot(motion_vector)
	if forward_angle > 0:
		var lift_percent := forward_angle
		var lift_amount := (base_lift + _upgrade_lift) * lift_percent
		var speed := state.linear_velocity.length()
		
		var envelope_percent := control_envelope.sample_baked(speed)
		state.apply_central_impulse(state.step * lift_vector * lift_amount * envelope_percent)
		_stats.lift = "%.3f" % [lift_amount]
	else:
		_stats.lift = "0.0"

# Control affects the ability to adjust your direction and keep going 'forward' instead of tumbling
func _apply_control(state: PhysicsDirectBodyState3D):
	var motion_vector := state.linear_velocity.normalized()
	var forward_vector := state.transform.basis * Vector3.MODEL_FRONT
	var forward_angle := forward_vector.dot(motion_vector)
	if forward_angle > 0 && state.linear_velocity.length() > 0.1:
		var lv := state.linear_velocity
		var speed := lv.length()
		var control_amount := clampf(base_control + _upgrade_control, 0.0, 1.0)
		# less control = continue in the current direction
		var desired_velocity := lv.normalized().lerp(forward_vector, control_amount) * speed
		var control_impulse := (desired_velocity - state.linear_velocity) * mass
		var envelope_percent := control_envelope.sample_baked(speed)
		state.apply_central_impulse(state.step * control_impulse * envelope_percent)
		_stats.control_impulse = "\n".join(["",linear_velocity, desired_velocity, control_impulse])
	#else:
	#_stats.control_impulse = "0.0"
	


func _on_move_button_button_down() -> void:
	_thrust_vector = Vector3.BACK
	sleeping = false


func _on_move_button_button_up() -> void:
	_thrust_vector = Vector3()


func _update_distances():
	speed_str = "Speed: %.2f m/s" % [linear_velocity.length()]
	var start_pos := _impact_point if _impact_point != Vector3.ZERO else global_position
	flight_distance = start_pos.distance_to(_launch_point)
	roll_distance = global_position.distance_to(_impact_point) if _landed else 0.0
	flight_distance_str = ("Flight Distance: %.2f m" % [flight_distance]) if flight_distance > 5.0 else ""
	roll_distance_str = ("Roll Distance: %.2f m" % [roll_distance]) if roll_distance > 5.0 else ""
	distance_updated.emit()


func _print_stats():
	var ps := %PhysicsStats as Label
	var stats := []
	for k in _stats:
		stats.append("%s: %s" % [k, _stats[k]])
	ps.text = "\n".join([
		speed_str,
		flight_distance_str,
		roll_distance_str,
		"\n".join(stats)
	])

func _unhandled_input(event: InputEvent) -> void:
	_player_inputs = Vector3.ZERO
	_thrust_vector = Vector3.ZERO
	if !_landed:
		_player_inputs += Vector3.LEFT * Input.get_action_strength("move_left")
		_player_inputs += Vector3.RIGHT * Input.get_action_strength("move_right")
		_player_inputs += Vector3.UP * Input.get_action_strength("move_down")
		_player_inputs += Vector3.DOWN * Input.get_action_strength("move_up")
		_thrust_vector = Vector3.BACK * Input.get_action_strength("move_forward")
	
	%ThrustParticles.amount_ratio = 0.5 +  _thrust_vector.length()
	%ThrustParticles.emitting = _thrust_vector.length() > 0.1
	if _player_inputs.length_squared() > 0:
		sleeping = false
