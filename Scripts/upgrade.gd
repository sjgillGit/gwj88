class_name Upgrade
extends Node3D

enum UpgradeCategory {
	HEAD,
	COLLAR,
	ANTLER,
	ORNAMENT,
	SADDLE,
	SADDLE_SIDE,
	SADDLE_TOP
}

@export var upgrade_name = ""
@export var id = ""
@export_multiline var description = ""
@export var requires = ""
@export var cost := 1000
@export var enabled := false:
	set(value):
		enabled = value
		visible = value
@export var category := UpgradeCategory.HEAD

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
