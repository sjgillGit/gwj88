extends Node3D

func set_run_speed(value: float):
	var at := %AnimationTree
	at.set("parameters/running/blend_amount", absf(value))
	at.set("parameters/run_timescale/scale", value * 3)


func _ready() -> void:
	_update_upgrades()
	DeerUpgrades.upgrades_updated.connect(_update_upgrades)


func _get_upgrade_node_3ds() -> Array[Upgrade]:
	var found: Array[Upgrade]
	for child in find_children("*", "Node3D"):
		if child is Upgrade:
			found.append(child)
	return found


func _update_upgrades():
	var upgrades = DeerUpgrades.get_upgrades()
	for child in _get_upgrade_node_3ds():
		if child.category in upgrades:
			if child.category == DeerUpgrades.Category.SMALL_ANTLERS \
			and DeerUpgrades.Category.LARGE_ANTLERS in upgrades:
				child.hide()
			else:
				child.show()
