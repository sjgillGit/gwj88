class_name Reindeer
extends Node3D

signal elf_thrown()

@onready var pellet_producer: PelletProducer = %PelletProducer

var horns_down: float = 0.0:
	set(v):
		horns_down = v
		if is_inside_tree():
			%AnimationTree.set("parameters/horns_down/add_amount", horns_down)

func show_holiday_spirit(value: bool):
	if value:
		%AnimateHolidaySpirit.play("holiday_spirit")
	else:
		%AnimateHolidaySpirit.stop()

	%AudioHolidaySpirit.playing = value && %"U Collar UPGRADE".enabled
	%HSLights.visible = value && %"U Ornaments UPGRADE".enabled
	%HSLights2.visible = value && %"U Collar UPGRADE".enabled


func set_run_speed(value: float):
	assert(value >= -1.0 && value <= 1.0)
	var at := %AnimationTree
	at.set("parameters/run_timescale/scale", absf(value) * 3)
	at.set("parameters/running/blend_amount", value)


func deflect():
	var pb := %AnimationTree.get("parameters/deflect/playback") as AnimationNodeStateMachinePlayback
	pb.start("Deflect", true)

func throw_elf():
	if !%Elf.freeze:
		return
	var pb := %AnimationTree.get("parameters/throw_elf/playback") as AnimationNodeStateMachinePlayback
	pb.start("Throw", true)
	%ThrowElfTimer.start()

func _on_throw_elf_timer_timeout() -> void:
	var elf := %Elf
	elf.freeze = false
	elf.sleeping = false
	elf.top_level = true
	var ap := elf.get_node_or_null("NonWilhelmScream") as AudioStreamPlayer3D
	ap.play()
	var cs := elf.get_node_or_null("CollisionShape3D")
	if cs:
		cs.disabled = false
	elf.apply_central_impulse(global_basis * Vector3(-10.0, 0, 0))
	elf_thrown.emit()

func _ready() -> void:
	set_run_speed(0)
	_update_upgrades()
	DeerUpgrades.upgrades_updated.connect(_update_upgrades)
	show_holiday_spirit(false)


func _get_upgrade_node_3ds() -> Array[Upgrade]:
	var found: Array[Upgrade]
	for child in find_children("*", "Node3D"):
		if child is Upgrade:
			found.append(child)
	return found


func _update_upgrades():
	var enabled_upgrades = DeerUpgrades.get_upgrades()
	for u in get_upgrades():
		u.enabled = u.category in enabled_upgrades


func get_upgrades():
	var result: Array[Upgrade]
	for c in find_children("*", "Node3D"):
		if c is Upgrade:
			result.append(c)
	return result

## hack because elf is made of a bunch of different cubes!
func _on_cube_visibility_changed() -> void:
	var e:bool = $metarig/Skeleton3D/Cube.enabled
	for cube in [
		$metarig/Skeleton3D/Cube_001,
		$metarig/Skeleton3D/Cube_002,
		$metarig/Skeleton3D/Cube_003,
		$metarig/Skeleton3D/Cube_004,
		$metarig/Skeleton3D/Cube_005,
		$metarig/Skeleton3D/Cube_006,
		$metarig/Skeleton3D/Cube_007,
		$metarig/Skeleton3D/Cube_008,
		$metarig/Skeleton3D/Cube_009,
		$metarig/Skeleton3D/Cube_010,
		$metarig/Skeleton3D/Cylinder
	]:
		cube.visible = e
