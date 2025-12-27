class_name Upgrade
extends Node3D

signal thrusting_changed(value: bool)

@export var overridden_by := DeerUpgrades.Category.NONE
@export var enabled := false:
	set(value):
		enabled = value
		var overridden = DeerUpgrades.get_upgrades().any(func(u): return u == overridden_by)
		visible = value && !overridden
@export var category : DeerUpgrades.Category

@export var store_thumbnail: Texture

#upgrade_stats
@export var stats: UpgradeStats

@onready var _ignite_audio :AudioStreamPlayer3D = get_node_or_null("IgniteAudio")
@onready var _burn_audio :AudioStreamPlayer3D = get_node_or_null("BurnAudio")
@onready var _extinguish_audio :AudioStreamPlayer3D = get_node_or_null("ExtinguishAudio")

var _fuel_seconds := 0.0
var _thrusting := false

func _ready():
	enabled = enabled
	_fuel_seconds = stats.fuel_capacity_seconds if stats else 0


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
			end_thrust()


func start_thrust():
	if _fuel_seconds > 0:
		_thrusting = true
		thrusting_changed.emit(_thrusting)
		if _ignite_audio:
			_ignite_audio.play()
		if _burn_audio:
			_burn_audio.play()


func end_thrust():
	_thrusting = false
	if _burn_audio:
		if _burn_audio.playing && _extinguish_audio:
			_extinguish_audio.play()
		_burn_audio.stop()
	thrusting_changed.emit(_thrusting)

func get_control():
	return stats.control if _thrusting || stats.fuel_capacity_seconds == 0 else 0


func get_thrust():
	return stats.thrust if _thrusting && _fuel_seconds > 0 else 0.0


func get_lift():
	return stats.lift


func get_drag():
	return stats.drag


func get_mass():
	return stats.mass
