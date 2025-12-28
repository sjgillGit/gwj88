class_name DeerMissile
extends RigidBody3D

signal distance_updated()
signal flight_state_changed(state: FlightState)

const FlightState = preload("res://Scripts/flight_state.gd").FlightState

@export var ramp_downforce := 4.0

@export var base_thrust := 0.0
@export var base_lift := 0.0
@export_range(0.0, 0.1, 0.00001) var base_drag := 0.00006
@export var base_mass := 50.0
## Amount of control you have over flight.. should be between 0 and 1
@export_range(0, 1.0, 0.01) var base_control := 0.4
## speeds at which we have flight control
@export var control_envelope: Curve
@export var setup_seconds := 10.0
@export var snowball_block_seconds := 0.5
@export var snowball_block_range := 1.0

@export var walk_speed := 5.0
@export var pitch_speed := 0.5
@export var yaw_speed := 0.25

@export var max_follow_cam_degrees := 80.0

## This should be a fraction, every frame it tries to get to the
## 'ideal' roll by roll_speed% of the distance
@export_range(0.0, 1.0, 0.01) var roll_speed := 0.05
@export_range(0.0, PI, 0.1) var roll_limit := PI * 0.25
@export_range(0.0, 10.0, 0.001) var roll_correction_speed := 0.5
@export_range(0.0, 10.0, 0.001) var camera_follow_speed_distance := 0.1

## time you need to hold left or right to get the 'do a barrel roll' prompt on keyboard
## on controller it will be the amount of input
@export var barrel_roll_hold_seconds := 0.2


@export var show_debug_ui := false:
	set(value):
		show_debug_ui = value
		if is_node_ready() && EngineDebugger.is_active():
			%DebugUi.visible = value

@export_category("GUIDE")
@export var movement: GUIDEAction
@export var boost: GUIDEAction

@onready var camera_animation := %CameraAnimationPlayer

@onready var _ramp_skid_sfx := $AudioRampSkid as AudioStreamPlayer3D
@onready var _hoof_beats_sfx := $AudioHoofBeats as AudioStreamPlayer3D
@onready var _collide_sfx := $AudioCollision as AudioStreamPlayer3D
@onready var _snow_slide_sfx := $AudioSnowSlide as AudioStreamPlayer3D
@onready var _boost_sfx := $AudioBigBoost as AudioStreamPlayer3D
@onready var _boost_small_sfx := $AudioSmallBoost as AudioStreamPlayer3D
@onready var _elf_gib_b_sfx := $AudioElfGibberishB as AudioStreamPlayer3D
@onready var _particle_repellant := %GPUParticlesAttractorVectorField3D as GPUParticlesAttractorVectorField3D
@onready var _snow_debris_particles := %GPUParticlesSnowDebris


var flight_distance := 0.0
var roll_distance := 0.0

## string versions of these stats
var flight_distance_str := ""
var roll_distance_str := ""
var money_collected := 0
var speed_str := ""

var end_timer_running := false

var _launch_point: Vector3
var _impact_point: Vector3

# Update this vector to apply thrust in a specific direction (usually BACK)
var _thrust_vector := Vector3.BACK
var _upgrade_thrust := 0.0
var _upgrade_lift := 0.0
var _upgrade_drag := 0.0
var _upgrade_control := 0.0
var _upgrade_walk_speed := 0.0
var _upgrade_ramp_downforce := 0.0
var _upgrade_holiday_spirit := 0.0
var _upgrade_toughness := 0.0
var _player_inputs: Vector3
var _input_x_hold_time := 0.0
var _on_platform := true
var _on_ramp := false
var _on_ground := false
var _in_launch_zone := false
var _in_staging_area := false
var _stats := {}
var _landed := false
var _launch_upgrades: Array[Upgrade]

var _holiday_spirit_activated := false
var _holiday_spirit_on_cooldown := false

var _default_angular_damp := angular_damp

var _wind_detector_areas: Array[int]
var _overlapping_areas: Array[int]
var _current_flight_state := FlightState.SETUP
var _setup_time_left := 0.0
var _camera_mark_pos := Vector3()

var _wind_time := 0.0
var _wind_amount := 0.0
var _snowballs: Array = []
var _debris: Array[int]
var _last_debris_pos: Vector3

var _qte_snowball: QuickTimeEventScreen.QTE
var _qte_start: QuickTimeEventScreen.QTE
var _qte_end: QuickTimeEventScreen.QTE
var _qte_wind: QuickTimeEventScreen.QTE
var _qte_barrel_roll: QuickTimeEventScreen.QTE

@onready var _wind_indicator := %WindIndicator


func _ready():
	# when running the scene directly from the editor, we want some upgrades
	for a in  OS.get_cmdline_args():
		if a.ends_with('flight_main.tscn'):
			DeerUpgrades._upgrades = [
				DeerUpgrades.Category.SMALL_ANTLERS,
				DeerUpgrades.Category.COLLAR,
				DeerUpgrades.Category.WINGS,
				DeerUpgrades.Category.ROCKETS
			]
			break
	# invoke setter!
	_setup_time_left = setup_seconds
	center_of_mass = %CenterOfMassMarker.transform.origin
	if !control_envelope:
		control_envelope = Curve.new()
		control_envelope.add_point(Vector2(0, 0))
		control_envelope.add_point(Vector2(2, 1.0))
		control_envelope.add_point(Vector2(120, 1.0))
		control_envelope.add_point(Vector2(200, 0))
	show_debug_ui = show_debug_ui
	# don't worry about the upgrade changed signal,
	# they can't be toggled in this game state
	set_enabled_upgrades(DeerUpgrades.get_upgrades())

	await get_tree().process_frame
	$FollowCamera.transform = $CameraFollowMark.transform
	_flight_state_changed(FlightState.SETUP)
	_setup_quick_time_action_to_start()


func _setup_quick_time_action_to_start():
	_qte_start = QuickTimeEventScreen.add_quick_time_event(
		self,
		"Start the run",
		1,
		setup_seconds,
		(func (_unused):
		if _current_flight_state < FlightState.PRE_FLIGHT:
			_flight_state_changed(FlightState.PRE_FLIGHT)
			%TimeLeftLabel.visible = false
			if _qte_start:
				_qte_start.queue_free()
				_qte_start = null
		),
	)


func get_flight_state() -> FlightState:
	if _current_flight_state in [FlightState.SETUP, FlightState.POST_FLIGHT]:
		return _current_flight_state
	if _landed && linear_velocity.length() < 0.01:
		return FlightState.POST_FLIGHT
	if _launch_point != Vector3.ZERO && !_in_launch_zone:
		return FlightState.FLIGHT
	return _current_flight_state


func _flight_state_changed(new_state: FlightState):
	print("Change FlightState, %s -> %s" % [
		FlightState.keys()[_current_flight_state],
		FlightState.keys()[new_state]
	])
	if new_state < _current_flight_state:
		assert(false, "Found it!")
	_current_flight_state = new_state
	if _current_flight_state == FlightState.SETUP:
		axis_lock_linear_z = true
		axis_lock_angular_y = true
	else:
		axis_lock_linear_z = false
		axis_lock_angular_y = false
	if _current_flight_state == FlightState.PRE_FLIGHT:
		camera_animation.speed_scale = 100.0
		%TimeLeftLabel.visible = false
		$AudioCountDownFinished.play()
		_qte_start.cancel_action()
	if _current_flight_state == FlightState.FLIGHT:
		_camera_mark_pos = %CameraFollowMark.position
		for u in _launch_upgrades:
			u.start_thrust()
		%CollisionPolygonFeet.disabled = true
		angular_velocity = Vector3.ZERO
	if _current_flight_state == FlightState.POST_FLIGHT:
		angular_damp = 0.5
		linear_damp = 0.5
		if _qte_start:
			_qte_start.free()
			_qte_start = null
	flight_state_changed.emit(_current_flight_state)


func _on_flight_state_timer_timeout() -> void:
	if _current_flight_state == FlightState.SETUP:
		if _setup_time_left > 0:
			_setup_time_left -= $FlightStateTimer.wait_time
			%TimeLeftLabel.visible = true
			%TimeLeftLabel.text = "< %d >" % _setup_time_left
			if _setup_time_left <= 3:
				$AudioCountDown.play()
		else:
			_flight_state_changed(FlightState.PRE_FLIGHT)
	var flight_state := get_flight_state()
	_update_distances()
	if flight_state != _current_flight_state:
		_flight_state_changed(flight_state)


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
	return %Reindeer.get_upgrades()


func _apply_upgrade_stats():
	# TODO: add up stats from current upgrades and save them in `_upgrade_x` vars
	var _upgrade_mass = 0 # (no upgrades yet!)
	_upgrade_lift = 0
	_upgrade_thrust = 0
	_upgrade_drag = 0
	_upgrade_control = 0
	_upgrade_walk_speed = 0
	_upgrade_ramp_downforce = 0
	_upgrade_toughness = 0
	_upgrade_holiday_spirit = 0
	for u in _launch_upgrades:
		_upgrade_mass += u.get_mass()
		_upgrade_control += u.get_control()
		_upgrade_thrust += u.get_thrust()
		_upgrade_lift += u.get_lift()
		_upgrade_drag += u.get_drag()
		_upgrade_walk_speed += u.stats.ramp_walk_speed
		_upgrade_ramp_downforce += u.stats.ramp_downforce
		_upgrade_toughness += u.stats.toughness
		_upgrade_holiday_spirit += u.stats.holiday_spirit

	# mass is the only builtin stat on RigidBody3D
	mass = base_mass + _upgrade_mass


func _is_terrain(b: Node3D) -> Ground:
	var p := b
	while p:
		if p is Ground:
			return p
		var pp = p.get_parent()
		p = pp if pp is Node3D else null
	return null


func _setup_quick_time_event_landed():
	if !end_timer_running:
		_qte_end = QuickTimeEventScreen.add_quick_time_event(
			self,
			"End this run and collect rewards",
			6,
			INF,
			(func(_unused):
			_flight_state_changed(FlightState.POST_FLIGHT)
			if _qte_end:
				_qte_end.queue_free()
				_qte_end = null
			)
		)


func activate_holiday_spirit(value: bool):
	%Reindeer.show_holiday_spirit(value)
	_holiday_spirit_activated = value
	if value:
		_holiday_spirit_on_cooldown = true
		$HSCooldown.start()
	else:
		if _qte_wind:
			_qte_wind.queue_free()

## 0.0, 1.0, 2.0
func get_holiday_spirit() -> float:
	if _holiday_spirit_activated:
		return _upgrade_holiday_spirit
	return 0.0


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var _distance_updated := false
	_on_ramp = false
	_on_platform = false
	_on_ground = false
	_apply_upgrade_stats()
	var on_snow := 0.0
	var cb := get_colliding_bodies()
	for b in cb:
		var ground := _is_terrain(b) if b is not Ground else b
		if b is PhysicalRamp:
			_launch_point = global_position
			_impact_point = Vector3()
			_distance_updated = true
			_on_ramp = true
		elif ground:
			_on_ground = true
			var tb := ground as TerraBrush
			if tb:
				var pos := tb.global_transform.affine_inverse() * global_position
				var ti := tb.getPositionInformation(pos.x, pos.z)
				var sf := ti.get_snowFactor()
				on_snow = maxf(sf - tb.snowDefinition.snowFactor, 0.0)
				if on_snow < 0.0:
					print(sf)
					pass

			if !_landed:
				_impact_point = global_position
				_distance_updated = true
				_landed = true
				$FollowCamera.allow_attach = false
				for u in _launch_upgrades:
					u.end_thrust()
				_setup_quick_time_event_landed()
		elif b is TopPlatform:
			_on_platform = true
	if _current_flight_state in [FlightState.PRE_FLIGHT, FlightState.POST_FLIGHT] && !_on_ramp || _landed:
		angular_damp = 0.98
	else:
		angular_damp = _default_angular_damp

	_update_input(state.step)
	_update_wind(state)
	_update_snowballs(state)

	var global_thrust := global_basis * _thrust_vector * (base_thrust + _upgrade_thrust)
	state.apply_central_force(global_thrust)

	_apply_drag(state)
	_apply_lift(state)
	_apply_control(state)

	_apply_player_input(state)

	%CameraSnow.amount_ratio = minf(linear_velocity.length(), 1.0)
	if _distance_updated:
		_update_distances()
	var forward_speed := (state.transform.basis.inverse() * state.linear_velocity).z
	if _camera_mark_pos && forward_speed > -1.0:
		var follow_cam_dir := Vector3.MODEL_REAR
		if forward_speed > 0:
			var local_velocity_dir_inv = -(state.transform.basis.inverse() * state.linear_velocity.normalized())
			var angle := acos(local_velocity_dir_inv.dot(follow_cam_dir))
			var max_angle := deg_to_rad(max_follow_cam_degrees)
			if angle > max_angle:
				follow_cam_dir = local_velocity_dir_inv.slerp(follow_cam_dir, max_angle / angle)
			else:
				follow_cam_dir = local_velocity_dir_inv
		%CameraFollowMark.position = _camera_mark_pos + follow_cam_dir * forward_speed * camera_follow_speed_distance

	var run_speed = forward_speed
	if run_speed > walk_speed && _current_flight_state != FlightState.FLIGHT:
		# skid and 'try to slow down' if going too fast
		run_speed = walk_speed - run_speed
	run_speed = clampf(run_speed / walk_speed , -1.0, 1.0)
	if abs(run_speed) < 0.001:
		run_speed = 0
	%Reindeer.set_run_speed(run_speed)
	_apply_sfx(run_speed)
	_print_stats()
	var lv_len := state.linear_velocity.length()
	var min_dist := clampf((1.0 - minf(lv_len / 5.0, 1.0)) * 1, 0.1, 1.0)

	_snow_debris_particles.emitting = false
	if on_snow > 0.0 && lv_len > 1.0 && _last_debris_pos.distance_to(state.transform.origin) > min_dist:
		var d := preload("res://Scenes/environment/icicle_debris.tscn").instantiate()
		get_parent().add_child(d)
		d.mesh_scale = clampf(lv_len * on_snow, 1.0, 3.0)
		_snow_debris_particles.emitting = true
		_snow_debris_particles.amount_ratio = clampf(lv_len * on_snow, 0.0, 1.0)
		var randv := Vector3(randf_range(-0.4, 0.4),randf_range(-0.2, 0.2), randf_range(-0.4, 0.4))
		var speed_dist := clampf(lv_len, 0.5, 2.0)
		d.global_position = %CenterOfMassMarker.global_position + state.linear_velocity.normalized() * speed_dist + randv
		_snow_debris_particles.global_position = d.global_position
		_debris.append(d.get_instance_id())
		_last_debris_pos = state.transform.origin
		if len(_debris) > 200 || Engine.get_frames_per_second() < 25:
			var id = _debris.pop_front()
			d = instance_from_id(id)
			if d:
				d.queue_free()


func _update_wind(state: PhysicsDirectBodyState3D):
	var wind_direction := Vector3()
	var wind_strength := 0.0
	var hs := get_holiday_spirit()
	for a_id in _overlapping_areas:
		var a := instance_from_id(a_id)
		if a is DeerArea:
			a.apply_physics(state, mass)
			if a is Wind:
				var ws = a.get_wind_strength_w_hs(hs)
				wind_strength += ws
				wind_direction += a.get_global_wind_direction() * ws
				_try_show_hs_qte(hs)
	if len(_wind_detector_areas):
		_try_show_hs_qte(hs)
	var wrs := (hs * 50.0)
	_particle_repellant.strength = wrs
	if wind_direction:
		_wind_amount = wind_direction.length()
		if _wind_time < 2.0:
			_wind_time += state.step
		_wind_indicator.global_transform.basis = Basis().looking_at(wind_direction.normalized())
	elif _wind_time > 0:
		_wind_time -= state.step * 2.0

	var wind_time_amount := minf(_wind_time * 0.5, 1.0)
	var opacity := clampf(_wind_amount / 15.0 * wind_time_amount, 0.0, 1.0)
	_stats.wind_opacity = opacity
	for mi: MeshInstance3D in _wind_indicator.find_children("*", "MeshInstance3D"):
		mi.transparency = 1.0 - opacity
	_wind_indicator.visible = opacity > 0


func _try_show_hs_qte(hs: float):
	var can_use := _current_flight_state == FlightState.FLIGHT && \
		_upgrade_holiday_spirit > 0 && !_holiday_spirit_activated && \
		!_holiday_spirit_on_cooldown
	if !_qte_wind && can_use:
		_qte_wind = QuickTimeEventScreen.add_quick_time_event(
			self,
			"Activate Holiday Spirit",
			4,
			4,
			(func(success):
			if success:
				activate_holiday_spirit(true)
			_qte_wind.queue_free()
			_qte_wind = null
			)

		)

func _update_snowballs(state: PhysicsDirectBodyState3D):
	if _qte_snowball != null || _upgrade_toughness < 1.0 || _current_flight_state != FlightState.FLIGHT:
		return
	for snowball: Snowball in _snowballs:
		var self_pred_pos := state.transform.origin + state.linear_velocity * snowball_block_seconds
		var current_dist_s := snowball.global_position.distance_to(self_pred_pos) / snowball.velocity.length()
		var pred_pos := snowball.global_position + snowball.velocity * minf(snowball_block_seconds, current_dist_s)
		var dist := pred_pos.distance_to(self_pred_pos)
		_stats.snowball = "\n".join([
			"dist: %s" % [dist],
			"s_pos: %s" % [snowball.global_position],
			"s_pred_pos: %s" % [pred_pos],
			"d_pos: %s" % [state.transform.origin],
			"d_pred_pos: %s" % [self_pred_pos]
		])
		_stats.snowball_pos = {
			s=pred_pos,
			d=self_pred_pos
		}
		if dist < snowball_block_range + snowball.size:
			_qte_snowball = QuickTimeEventScreen.add_quick_time_event(
				self,
				"Deflect snowball",
				5,
				snowball_block_seconds * _upgrade_toughness,
				(func (success):
				if success:
					%Reindeer.deflect()
					if _snowballs.size() > 0:
						for sn: Node in _snowballs:
							if sn.is_inside_tree():
								sn.parry()
						_snowballs.clear()
				if _qte_snowball:
					_qte_snowball.queue_free()
					_qte_snowball = null
				)
			)
			break

func _apply_sfx(run_speed: float):
	# quantize a bit so it doesn't sound like a slide whistle...
	var ps := clampf(round(absf(run_speed) / walk_speed) * (1 / 3.0), 0.5, 1.5)
	var volume := clampf((absf(run_speed) / (walk_speed * 1.0)) * 1.0, 0.0, 0.2)
	_ramp_skid_sfx.pitch_scale = ps

	_ramp_skid_sfx.volume_linear = volume
	if _ramp_skid_sfx.playing != _on_ramp:
		_ramp_skid_sfx.playing = _on_ramp
	var y_up := global_basis.y.y > 0.75
	# todo: cast to ground to find normal of ground
	var walking := (_on_ramp || _on_platform || (_on_ground && y_up)) && run_speed > 0.0

	ps = clampf(round(absf(run_speed) / walk_speed) * (1 / 3.0), 0.75, 1.1)
	_hoof_beats_sfx.volume_linear = volume
	_hoof_beats_sfx.pitch_scale = ps
	var bus_idx := AudioServer.get_bus_index(_hoof_beats_sfx.bus)
	var pse := AudioServer.get_bus_effect(bus_idx, 0) as AudioEffectPitchShift
	pse.pitch_scale = 1.0 / ps
	if _hoof_beats_sfx.playing != walking:
		_hoof_beats_sfx.playing = walking
	var sliding = _on_ground && linear_velocity.length() > 0.1
	# todo: detect snow from terrain
	if sliding != _snow_slide_sfx.playing:
		_snow_slide_sfx.playing = sliding
	_snow_slide_sfx.volume_linear = clampf(linear_velocity.length() / 100.0, 0.0, 0.1)


func _apply_player_input(state: PhysicsDirectBodyState3D):
	var gbasis := state.transform.basis
	if _current_flight_state == FlightState.SETUP:
		if _in_staging_area:
			state.apply_central_force(gbasis * (Vector3.LEFT * _player_inputs.x * walk_speed * mass))
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
			state.apply_torque(gbasis * (Vector3.DOWN * _player_inputs.x * yaw_speed * mass))
			# Y inputs ignored while launching, we just have constant forward
			state.apply_central_force(gbasis * (Vector3.BACK * walk_speed * mass))
	elif !_landed && _current_flight_state == FlightState.FLIGHT:
		# X inputs rotate around the Y axis (yaw)
		state.apply_torque(gbasis * (Vector3.DOWN * _player_inputs.x * yaw_speed * mass))
		# Y inputs rotate around the X axis (pitch)
		state.apply_torque(gbasis * (Vector3.LEFT * _player_inputs.y * pitch_speed * mass))

		var roll_target := clampf(_player_inputs.x * roll_limit, -roll_limit, roll_limit)
		%FlightRoll.rotation.z = lerp(%FlightRoll.rotation.z, roll_target, roll_speed)

		# automatically roll 'upward' until your z rotation is 0
		var local_av := gbasis.inverse() * state.angular_velocity
		var up_vector := (gbasis.inverse() * Vector3.UP * Vector3(1.0, 1.0, 0.0)).normalized()
		var up_dist := up_vector.x
		if up_vector.y > 0.0: #&& abs(up_dist) > 0.001:
			var amount := up_dist
			var accel := local_av.z - up_dist
			if up_dist < 0:
				accel *= -1
			if accel > 0:
				amount = local_av.z * 5.0
			state.apply_torque(gbasis * roll_correction_speed * amount * Vector3.FORWARD * mass)
	elif _landed:
		# If you are not landing 'upward' play the fetal position pose
		var local_av := gbasis.inverse() * state.angular_velocity
		var up_vector := (gbasis.inverse() * Vector3.UP * Vector3(1.0, 1.0, 0.0)).normalized()
		var up_dist := up_vector.y
		assert(up_dist <= 1.0)
		%Reindeer.horns_down = minf(1.0 - up_dist, 1.0)


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


func _update_distances():
	var hspeed := (linear_velocity * Vector3(1.0, 0.0, 1.0)).length()
	speed_str = "Speed: %.2f m/s" % [hspeed]
	var start_pos := _impact_point if _impact_point != Vector3.ZERO else global_position
	flight_distance = start_pos.distance_to(_launch_point)
	roll_distance = global_position.distance_to(_impact_point) if _landed && _impact_point else 0.0
	flight_distance_str = ("Flight Distance: %.2f m" % [flight_distance]) if flight_distance > 5.0 else ""
	roll_distance_str = ("Roll Distance: %.2f m" % [roll_distance]) if roll_distance > 5.0 else ""
	distance_updated.emit()


func _print_stats():
	var ps := %PhysicsStats as Label
	var stats := []
	for k in _stats:
		if _stats[k] is String:
			stats.append("%s: %s" % [k, _stats[k]])
	ps.text = "\n".join([
		speed_str,
		flight_distance_str,
		roll_distance_str,
		"\n".join(stats),
		"fps: %s" % [Engine.get_frames_per_second()]
	])

func _update_input(delta) -> void:
	if _landed:
		_player_inputs = Vector3.ZERO
		return

	# flying always should be 'stick forward to go down, stick backward to go up'...
	# probably should have a way to invert Y axis for weirdos
	_player_inputs = Vector3(clampf(movement.value_axis_2d.x, -1, 1), clampf(movement.value_axis_2d.y, -1, 1), 0)
	if _current_flight_state == FlightState.SETUP && abs(movement.value_axis_2d.y) > 0.5:
			_flight_state_changed(FlightState.PRE_FLIGHT)
	if _player_inputs.length_squared() > 0:
		sleeping = false
	if _player_inputs.x == 0:
		_input_x_hold_time = 0
	elif absf(_player_inputs.x) == 1.0:
		_input_x_hold_time += _player_inputs.x * delta
	else:
		_input_x_hold_time += _player_inputs.x * delta
	if absf(_player_inputs.x) > 0.5 && !_on_ground && _current_flight_state == FlightState.FLIGHT && abs(_input_x_hold_time) > barrel_roll_hold_seconds:
		var playback := %BarrelRollAnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback
		var node := playback.get_current_node()
		if !_qte_barrel_roll && node == "idle":
			_qte_barrel_roll = QuickTimeEventScreen.add_quick_time_event(
				self,
				"Do a Barrel Roll",
				1,
				INF,
				_do_a_barrel_roll
			)
	elif _qte_barrel_roll:
		_qte_barrel_roll.queue_free()
		_qte_barrel_roll = null


func _do_a_barrel_roll(success):
	if success:
		var state := "roll_right" if  _player_inputs.x > 0 else "roll_left"
		var playback := %BarrelRollAnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback
		playback.travel(state)
	if _qte_barrel_roll && !_qte_barrel_roll.is_queued_for_deletion():
		_qte_barrel_roll.queue_free()
	_qte_barrel_roll = null


func add_area(area: Area3D):
	if area is Booster:
		if area.speed_boost > 0:
			var pos :=  _boost_sfx.get_playback_position()
			if pos < 0.1 && _boost_sfx.playing:
				_boost_small_sfx.play()
			else:
				_boost_sfx.play()
		else:
			_elf_gib_b_sfx.play()
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
	elif area is Wind:
		if !len(_wind_detector_areas) && !_overlapping_areas.any(func(id):
			var a := instance_from_id(id)
			return a is Wind && a != area
		):
			activate_holiday_spirit(false)
	_overlapping_areas.erase(area.get_instance_id())


func _on_body_entered(body: Node) -> void:
	if body is PhysicalRamp:
		return
	var collision := _get_collision()
	if collision:
		var cv:Vector3 = linear_velocity * collision.normal
		var volume := clampf(cv.length() / 50, 0.25, 1.0)
		_collide_sfx.volume_linear = volume
		if volume > 0:
			_collide_sfx.play()
	else:
		_collide_sfx.volume_linear = 0.25
		_collide_sfx.play()


func _get_collision() -> Dictionary:
	var state := get_world_3d().direct_space_state
	var q := PhysicsShapeQueryParameters3D.new()
	q.collision_mask = collision_mask
	q.exclude = [get_rid()]
	for s: CollisionShape3D in find_children("*", "CollisionShape3D", false):
		q.transform = s.global_transform.translated(linear_velocity.normalized() * 0.5)
		q.shape = s.shape
		var rest_info := state.get_rest_info(q)
		if rest_info:
			return rest_info
	return {}

func add_snowball(snowball: Snowball) -> void:
	_snowballs.append(snowball)


func remove_snowball(snowball: Snowball) -> void:
	_snowballs.erase(snowball)


func _on_collecter_item_collected(item: Item) -> void:
	if item == preload("res://Scripts/collectibles/star_coin.tres"):
		money_collected += 1


func _on_hs_cooldown_timeout() -> void:
	_holiday_spirit_on_cooldown = false


func _on_sleeping_state_changed() -> void:
	if sleeping:
		%Reindeer.set_run_speed(0)


func _on_wind_detector_area_entered(area: Area3D) -> void:
	_wind_detector_areas.append(area.get_instance_id())


func _on_wind_detector_area_exited(area: Area3D) -> void:
	_wind_detector_areas.erase(area.get_instance_id())
	if !len(_wind_detector_areas) && !_overlapping_areas.any(func(id):
		return instance_from_id(id) is Wind
	):
		activate_holiday_spirit(false)
