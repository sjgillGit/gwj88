extends Node3D

func set_run_speed(value: float):
	var at := %AnimationTree
	at.set("parameters/running/blend_amount", absf(value))
	at.set("parameters/run_timescale/scale", value * 3)


func _ready() -> void:
	set_run_speed(0)
	_update_upgrades()
	DeerUpgrades.upgrades_updated.connect(_update_upgrades)


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
