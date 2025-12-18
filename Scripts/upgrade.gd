class_name Upgrade
extends Node3D

signal thrusting_changed(value: bool)

@export var upgrade_name = ""
@export_multiline var description = ""
@export var overridden_by := DeerUpgrades.Category.NONE
@export var cost := 1000
@export var enabled := false:
	set(value):
		enabled = value
		var overridden = DeerUpgrades.get_upgrades().any(func(u): return u == overridden_by)
		visible = value && !overridden
@export var category : DeerUpgrades.Category

# Upgrade stat static values
# use get_x() to get the current dynamic value
@export var thrust := 0.0
@export var lift := 0
@export var drag := 0
@export var mass := 1.0

## possible other stats?
# resist wind/snow? idk
@export var holiday_spirit := 0.0
# smash through walls?
@export var toughness := 0.0

@export var fuel_capacity_seconds := 0.0

var _fuel_seconds := 0.0
var _thrusting := false

func _ready():
	enabled = enabled
	_fuel_seconds = fuel_capacity_seconds


## allow getting collision shapes to add when this upgrade is enabled
func get_collision_shapes() -> Array[CollisionShape3D]:
	var result: Array[CollisionShape3D]
	if enabled:
		var cs := get_node_or_null('CollisionShape3D')
		if cs:
			result.append(cs)
	return result


func _physics_process(delta: float) -> void:
	if _thrusting:
		_fuel_seconds -= delta
		if _fuel_seconds <= 0:
			_thrusting = false
			thrusting_changed.emit(_thrusting)


func start_thrust():
	_thrusting = true
	thrusting_changed.emit(_thrusting)


func get_thrust():
	return thrust if _thrusting && _fuel_seconds > 0 else 0.0


func get_lift():
	return lift


func get_drag():
	return drag


func get_mass():
	return mass
