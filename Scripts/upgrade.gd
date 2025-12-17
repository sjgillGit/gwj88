class_name Upgrade
extends Node3D


@export var upgrade_name = ""
@export var id = ""
@export_multiline var description = ""
@export var requires = ""
@export var overrides = ""
@export var cost := 1000
@export var enabled := false:
	set(value):
		enabled = value
		visible = value
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


func _ready():
	enabled = enabled


## allow getting collision shapes to add when this upgrade is enabled
func get_collision_shapes() -> Array[CollisionShape3D]:
	var result: Array[CollisionShape3D]
	if enabled:
		var cs := get_node_or_null('CollisionShape3D')
		if cs:
			result.append(cs)
	return result

# virtual
func get_thrust():
	return thrust


# virtual
func get_lift():
	return lift


# virtual
func get_drag():
	return drag


# virtual
func get_mass():
	return mass
