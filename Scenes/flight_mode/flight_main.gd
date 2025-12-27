class_name FlightMain
extends Node3D

const FlightState = preload("res://Scripts/flight_state.gd").FlightState

@export_range(0.0, 1.0, 0.01) var music_volume := 0.075

var _player: DeerMissile
var _despawning := false
var _frame_time := 0.0
var _music_next: AudioStreamPlayer

func _ready():
	_spawn_deer()
	for n in $Collectibles.find_children("*"):
		var c := n as Collectible
		if c && c.item in GameStats.collectibles_collected:
			c.queue_free()


func _find_cams():
	var cams := find_children("*", "Camera3D", true, false)
	var co := %CameraOption as OptionButton
	co.clear()
	for c: Camera3D in cams:
		var i := co.item_count
		co.add_item(c.name)
		co.set_item_metadata(i, c.get_instance_id())
		if c.is_current():
			co.select(i)


func _spawn_deer():
	_despawning = true
	if _player:
		await get_tree().process_frame
		_player.free()
	_despawning = false
	_player = preload("./deer_missile.tscn").instantiate()
	_player.distance_updated.connect(_on_distance_updated)
	_player.flight_state_changed.connect(_on_flight_state_changed)
	add_child(_player)
	_player.global_transform = %DeerEmitter.global_transform
	var cams := _player.find_children("*", "Camera3D")
	if len(cams):
		cams[0].current = true
	_find_cams()
	var menu := _get_menu()
	if menu:
		menu.flight_state = UiPlay.FlightState.PRE_FLIGHT


func _get_menu() -> UiPlay:
	if !UiRootNode.instance:
		return null
	return UiRootNode.instance.get_menu_for_state(GameState.State.PLAY)


func _process(delta: float) -> void:
	_frame_time = delta

func _on_distance_updated():
	# TODO: update flight menu ui here?
	%FlightStats.text = "\n".join([
		_player.speed_str,
		_player.flight_distance_str,
		_player.roll_distance_str
	])
	%FPS.text = '%dFPS %.3fms(frame) 60fps = %.2fms\n%.2fms(cpu setup) %.2fms(phys) %.2fms(process)\n%d primitives' % [
		Engine.get_frames_per_second(),
		_frame_time * 1000.0,
		(1.0 / 60.0) * 1000.0,
		RenderingServer.get_frame_setup_time_cpu(),
		Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		RenderingServer.get_rendering_info(RenderingServer.RenderingInfo.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	]


func _on_ice_cube_button_pressed() -> void:
	var cube := %IceCube.duplicate() as RigidBody3D
	cube.transform = Transform3D()
	cube.linear_velocity = Vector3()
	cube.angular_velocity = Vector3()
	%IceCubeEmitter.add_child(cube)


func _on_camera_option_item_selected(index: int) -> void:
	if index >= 0:
		var co := %CameraOption as OptionButton
		var c := instance_from_id(co.get_item_metadata(index)) as Camera3D
		if c:
			c.current = true


func _on_flight_state_changed(flight_state: FlightState):
	if flight_state == FlightState.SETUP:
		$RampIntroJingleAudio.play()
	elif flight_state == FlightState.PRE_FLIGHT:
		$RampIntroJingleAudio.playing = false
		var upgrade_count = len(DeerUpgrades.get_upgrades())
		match upgrade_count:
			0,1:
				_play_music($Music1)
			2,3:
				_play_music($Music2)
			_:
				_play_music($Music3)
	var menu := _get_menu()
	if menu:
		if flight_state == FlightState.POST_FLIGHT:
			menu.flight_money = int(_player.flight_distance * 0.1)
			menu.roll_money = int(_player.roll_distance * 0.05)
			menu.coin_money = _player.money_collected
			GameStats.money += menu.flight_money + menu.roll_money
		menu.flight_state = flight_state
	elif flight_state == FlightState.POST_FLIGHT:
		# if we are debugging the scene, just restart
		_spawn_deer()


func _on_timer_timeout() -> void:
	_on_distance_updated()


func _on_play_area_body_exited(body: Node3D) -> void:
	# TODO: add different endings if you go out of the top or bottom
	if body is DeerMissile && !_despawning && _player.get_flight_state() != FlightState.POST_FLIGHT:
		_on_flight_state_changed(FlightState.POST_FLIGHT)


func _on_vsync_button_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED)


func _play_music(music: AudioStreamPlayer):
	for m in [$Music1, $Music2, $Music3, $MusicElf]:
		m.volume_linear = music_volume if m == music else 0.0
		m.play()

func _on_music_1_finished() -> void:
	if $Music1.volume_linear:
		_music_next = $Music2
		_play_music($MusicElf)

func _on_music_2_finished() -> void:
	if $Music2.volume_linear:
		_music_next = $Music3
		_play_music($MusicElf)


func _on_music_3_finished() -> void:
	if $Music3.volume_linear:
		_music_next = $Music1
		_play_music($MusicElf)


func _on_music_elf_finished() -> void:
	if $MusicElf.volume_linear:
		if _music_next:
			_play_music(_music_next)


func _on_ending_win_body_entered(body: Node3D) -> void:
	if body is DeerMissile:
		%EndTimer.start()


func _on_ending_space_body_entered(body: Node3D) -> void:
	if body is DeerMissile:
		GameState.current = GameState.State.ENDING_SPACE


func _on_ending_hole_body_entered(body: Node3D) -> void:
	if body is DeerMissile:
		GameState.current = GameState.State.ENDING_HOLE


func _on_ending_beach_body_entered(body: Node3D) -> void:
	if body is DeerMissile:
		GameState.current = GameState.State.ENDING_BEACH
