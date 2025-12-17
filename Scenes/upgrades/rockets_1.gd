extends Upgrade

func get_thrust() -> float:
	return thrust if _thrusting else 0.0

var _thrusting := false

func _physics_process(_delta: float) -> void:
	var dm := owner
	while dm && dm is not DeerMissile:
		dm = dm.owner
	if dm:
		_thrusting = dm.is_thrusting()
		for c in get_children():
			c.set_thrusting(_thrusting)
