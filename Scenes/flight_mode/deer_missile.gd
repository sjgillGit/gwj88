class_name DeerMissile
extends RigidBody3D

signal distance_updated()
signal flight_state_changed(state: FlightState)

const FlightState = preload("res://Scripts/flight_state.gd").FlightState

@export var ramp_downforce := 3.0

@export var base_thrust := 0.0
@export var base_lift := 0.0
@export_range(0.0, 0.1, 0.0001) var base_drag := 0.0001
@export var base_mass := 50.0
## Amount of control you have over flight.. should be between 0 and 1
@export_range(0, 1.0, 0.01) var base_control := 0.1
## speeds at which we have flight control
@export var control_envelope: Curve
@export var setup_seconds := 10.0

@export var walk_speed := 5.0
@export var pitch_speed := 1.0
@export var roll_speed := 1.0
@export var yaw_speed := 0.5

@export var show_debug_ui := true:
	set(value):
		if is_node_ready():
			%DebugUi.visible = value

@export_category("GUIDE")
@export var movement: GUIDEAction
@export var boost: GUIDEAction

var flight_distance := 0.0
var roll_distance := 0.0

## string versions of these stats
var flight_distance_str := ""
var roll_distance_str := ""
var speed_str := ""

var _launch_point: Vector3
var _impact_point: Vector3

# Update this vector to apply thrust in a specific direction (usually BACK)
var _thrust_vector := Vector3.BACK
var _upgrade_thrust := 0.0
var _upgrade_lift := 0.0
var _upgrade_drag := 0.0
var _upgrade_control := 0.0
var _player_inputs: Vector3
var _on_platform := true
var _on_ramp := false
var _in_launch_zone := false
var _in_staging_area := false
var _stats := {}
var _landed := false
var _launch_upgrades: Array[Upgrade]

var _default_angular_damp := angular_damp

var _overlapping_areas: Array[int]
var _current_flight_state := FlightState.SETUP
var _setup_time_left := 0.0


func _ready():
	# invoke setter!
	_setup_time_left = setup_seconds
	center_of_mass = %CenterOfMassMarker.transform.origin
	if !control_envelope:
		control_envelope = Curve.new()
		control_envelope.add_point(Vector2(0, 0))
		control_envelope.add_point(Vector2(2, 1.0))
		control_envelope.add_point(Vector2(120, 1.0))
		control_envelope.add_point(Vector2(200, 0))
	show_debug_ui = true # show_debug_ui
	# don't worry about the upgrade changed signal,
	# they can't be toggled in this game state
	set_enabled_upgrades(DeerUpgrades.get_upgrades())

	await get_tree().process_frame
	$FollowCamera.transform = $CameraFollowMark.transform
	_flight_state_changed()


func get_flight_state() -> FlightState:
	if _current_flight_state == FlightState.SETUP:
		return _current_flight_state
	if _landed && linear_velocity.length() < 0.01:
		return FlightState.POST_FLIGHT
	if _launch_point != Vector3.ZERO && !_in_launch_zone:
		return FlightState.FLIGHT
	return FlightState.PRE_FLIGHT


func _flight_state_changed():
	if _current_flight_state == FlightState.SETUP:
		axis_lock_linear_z = true
		axis_lock_angular_y = true
	else:
		axis_lock_linear_z = false
		axis_lock_angular_y = false
	if _current_flight_state == FlightState.FLIGHT:
		for u in _launch_upgrades:
			u.start_thrust()
		%CollisionPolygonFeet.disabled = true
		angular_velocity = Vector3.ZERO
	if _current_flight_state == FlightState.POST_FLIGHT:
		angular_damp = 0.5
		linear_damp = 0.5
	flight_state_changed.emit(_current_flight_state)


func _on_flight_state_timer_timeout() -> void:
	if _current_flight_state == FlightState.SETUP:
		if _setup_time_left > 0:
			_setup_time_left -= $FlightStateTimer.wait_time
			%TimeLeftLabel.visible = true
			%TimeLeftLabel.text = "< %d >" % _setup_time_left
		else:
			%TimeLeftLabel.visible = false
			_current_flight_state = FlightState.PRE_FLIGHT
			_flight_state_changed()
	var flight_state := get_flight_state()
	_update_distances()
	if flight_state != _current_flight_state:
		_current_flight_state = flight_state
		_flight_state_changed()


func set_enabled_upgrades(upgrades: Array[DeerUpgrades.Category]):
	_launch_upgrades.clear()
	for u in get_upgrades():
		u.enabled = u.category in upgrades
		if u.enabled:
			_launch_upgrades.append(u)

	for u in _launch_upgrades:
		var shapes := u.get_collision_shapes()
		for cs in shapes:
			var dup := cs.duplicate()
			add_child(dup)
			dup.global_transform = cs.global_transform


func get_upgrades() -> Array[Upgrade]:
	return $Reindeer.get_upgrades()


func _apply_upgrade_stats():
	# TODO: add up stats from current upgrades and save them in `_upgrade_x` vars
	var _upgrade_mass = 0 # (no upgrades yet!)
	_upgrade_lift = 0
	_upgrade_thrust = 0
	_upgrade_drag = 0
	for u in _launch_upgrades:
		_upgrade_mass += u.get_mass()
		_upgrade_thrust += u.get_thrust()
		_upgrade_lift += u.get_lift()
		_upgrade_drag += u.get_drag()

	# mass is the only builtin stat on RigidBody3D
	mass = base_mass + _upgrade_mass


func _is_terrain(b: Node3D) -> bool:
	var p := b.get_parent()
	while p:
		if p is Ground:
			return true
		p = p.get_parent()
	return false


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var _distance_updated := false
	_on_ramp = false
	_on_platform = false
	_apply_upgrade_stats()

	var cb := get_colliding_bodies()
	for b in cb:
		if b is PhysicalRamp:
			_launch_point = global_position
			_impact_point = Vector3()
			_distance_updated = true
			_on_ramp = true
		elif b is Ground || _is_terrain(b):
			_on_ramp = false
			if !_landed:
				_impact_point = global_position
				_distance_updated = true
				_landed = true
		elif b is TopPlatform:
			_on_platform = true
	if _current_flight_state == FlightState.PRE_FLIGHT && !_on_ramp:
		angular_damp = 0.98
	else:
		angular_damp = _default_angular_damp

	_update_input()

	for a_id in _overlapping_areas:
		var a := instance_from_id(a_id)
		if a is LaunchZone:
			# probably redundant, above code worked ok to detect _on_ramp status
			# but this is how to add boost areas also..
			_on_ramp = true
		elif a is DeerArea:
			a.apply_physics(state, mass)

	var local_thrust := global_basis * _thrust_vector * (base_thrust + _upgrade_thrust)
	state.apply_central_force(local_thrust)

	_apply_drag(state)
	_apply_lift(state)
	_apply_control(state)

	_apply_player_input(state)

	if _distance_updated:
		_update_distances()
	var _lv := state.linear_velocity
	var forward_speed := (state.transform.basis * state.linear_velocity).z
	forward_speed = clampf(forward_speed / walk_speed , -1.0, 1.0)
	if abs(forward_speed) < 0.001:
		forward_speed = 0

	%Reindeer.set_run_speed(forward_speed)
	_print_stats()

func _apply_player_input(state: PhysicsDirectBodyState3D):
	if _current_flight_state == FlightState.SETUP:
		if _in_staging_area:
			state.apply_central_force(global_basis * (Vector3.LEFT * _player_inputs.x * walk_speed * mass))
		elif _on_platform:
			var cb := get_colliding_bodies()
			var tp_idx := cb.find_custom(func(c): return c is TopPlatform)
			if tp_idx > -1:
				var tp := cb[tp_idx]
				var sa := tp.get_staging_area() as StagingArea
				if linear_velocity.length() < walk_speed * 0.1:
					state.apply_central_force((sa.global_position - global_position).normalized() * walk_speed * 0.1 * mass)

		# X inputs rotate around the Y axis (yaw) when we aren't flying
	if _current_flight_state == FlightState.PRE_FLIGHT:
		if _on_ramp || _on_platform:
			state.apply_torque(global_basis * (Vector3.DOWN * _player_inputs.x * roll_speed * mass))
			# Y inputs move forward/back when we aren't flying but we just have constant forward
			state.apply_central_force(global_basis * (Vector3.BACK * walk_speed * mass))

	else:
		# X inputs rotate around the Z axis (roll)
		state.apply_torque(global_basis * (Vector3.BACK * _player_inputs.x * roll_speed * mass))
		state.apply_torque(global_basis * (Vector3.DOWN * _player_inputs.x * yaw_speed * mass))
		# Y inputs rotate around the X axis (pitch)
		state.apply_torque(global_basis * (Vector3.LEFT * _player_inputs.y * pitch_speed * mass))
	# Z inputs rotate around the Y axis (yaw)
	# we don't actually have any inputs for this yet
	state.apply_torque(global_basis * (Vector3.DOWN * _player_inputs.z * yaw_speed * mass))


func _apply_drag(state: PhysicsDirectBodyState3D):
	var drag_amount := base_drag + _upgrade_drag
	drag_amount *= state.linear_velocity.length()
	var drag_vector := state.linear_velocity.normalized() * -1
	state.apply_central_force(drag_amount * drag_vector)
	_stats.drag = "%.3f" % [drag_amount]
	# higher speed = more drag..


func _apply_lift(state: PhysicsDirectBodyState3D):
	if _current_flight_state in [FlightState.PRE_FLIGHT, FlightState.SETUP] :
		_stats.lift = FlightState.find_key(_current_flight_state)
		var downforce_vector = state.transform.basis * Vector3.DOWN * ramp_downforce
		state.apply_central_force(downforce_vector * mass)
		return
	var lift_vector := state.transform.basis * Vector3.UP
	var motion_vector := state.linear_velocity.normalized()
	var forward_vector := state.transform.basis * Vector3.MODEL_FRONT
	var forward_angle := forward_vector.dot(motion_vector)
	var speed := state.linear_velocity.length()
	if forward_angle > 0 && speed > 0.1:
		var lift_percent := forward_angle
		var lift_amount := (base_lift + _upgrade_lift) * lift_percent

		var envelope_percent := control_envelope.sample_baked(speed)
		state.apply_central_force(lift_vector * lift_amount * envelope_percent)
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
		var control_force := (desired_velocity - state.linear_velocity) * mass
		var envelope_percent := control_envelope.sample_baked(speed)
		state.apply_central_force(control_force * envelope_percent)
		_stats.control_force = "\n".join(["", linear_velocity, desired_velocity, control_force])


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

func _update_input() -> void:
	if _landed:
		return

	# flying always should be 'stick forward to go down, stick backward to go up'...
	# probably should have a way to invert Y axis for weirdos
	_player_inputs = Vector3(clampf(movement.value_axis_2d.x, -1, 1), -clampf(movement.value_axis_2d.y, -1, 1), 0)
	if _current_flight_state == FlightState.SETUP && movement.value_axis_2d.y > 0.5:
			_current_flight_state = FlightState.PRE_FLIGHT
			_flight_state_changed()
			%TimeLeftLabel.visible = false
	if _player_inputs.length_squared() > 0:
		sleeping = false


func add_area(area: Area3D):
	if area is LaunchZone:
		_in_launch_zone = true
	elif area is StagingArea:
		_in_staging_area = true
	_overlapping_areas.append(area.get_instance_id())


func remove_area(area: Area3D):
	if area is LaunchZone:
		_in_launch_zone = false
	elif area is StagingArea:
		_in_staging_area = false
	_overlapping_areas.erase(area.get_instance_id())


func is_thrusting() -> bool:
	return _thrust_vector.length() > 0
